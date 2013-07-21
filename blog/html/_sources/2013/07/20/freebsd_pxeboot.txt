PXE boot + シェルスクリプトでFreeBSD 9.1のインストール自動化
###############################################################



.. author:: default
.. categories:: freebsd
.. tags:: freebsd
.. comments::


OSインストールをするだけでお金が貰えるならば喜んでやるが、趣味の時間をOSインストールに奪われるのはつらいので、自動化してみた。

PXE boot サーバ構築
***************************************************************

::

  # mdconfig -a -t vnode -f FreeBSD-9.1-RELEASE-amd64-disc1.iso
  md0
  # mount_cd9660 /dev/md0 /mnt
  # mkdir /var/pxeboot
  # cp -Rv /mnt/ /var/pxeboot
  # umount /mnt
  # mdconfig -d -u 0


::

  # vi /var/pxeboot/etc/fstab
  # /dev/iso9660/FREEBSD_INSTALL / cd9660 ro 0 0 <- コメントアウト


::

  # vi /etc/inetd.conf
  tftp    dgram   udp     wait    root    /usr/libexec/tftpd      tftpd -l -s /var/pxeboot/boot

  # /etc/rc.d/inetd onestart


::

  # cd /usr/ports/net/isc-dhcp42-server
  # make install

  # vi /usr/local/etc/dhcpd.conf
  ddns-update-style none;
  server-name "pxeboot";               # name of the tftp-server
  server-identifier 192.168.0.253;  # address of the tftp-server
  next-server 192.168.0.253;        # address of the NFS-server

  subnet 192.168.0.0 netmask 255.255.255.0 {
      range 192.168.0.220 192.168.0.250;
      option routers 192.168.0.254;
      option root-path "/var/pxeboot"; # root-path for NFS
      filename "pxeboot";                    # filename of NBP (network bootstrap program)
  }

  # /usr/local/etc/rc.d/isc-dhcpd onestart


::

  # vi /etc/exports
  /var/pxeboot -alldirs -maproot=root -ro

  # /etc/rc.d/nfsd onestart

再起動後もデーモンを起動させておきたければrc.confに書いておく。

::

  # vi /etc/rc.conf
  inetd_enable="YES"
  dhcpd_enable="YES"
  nfs_server_enable="YES"

FreeBSDインストールスクリプト
***************************************************************

PXE boot時に指定のスクリプトを実行するようにrc.localに書いておく。

::

  # vi /var/pxeboot/etc/rc.local

  #!/bin/sh
  # $FreeBSD: release/9.1.0/release/rc.local 232427 2012-03-03 02:13:53Z nwhitehorn $

  sh /root/freebsd_install.sh


このシェルスクリプトはPXE bootしたマシンのMACアドレスを見てマッチした[MACアドレス].confファイルに書かれたシェルスクリプトを実行するようになっている。

::

  # vi /var/pxeboot/root/freebsd_install.sh

  #!/bin/sh

  get_conf() {
    for a in $MACADDR; do
      find . -name ${a}.conf
    done
  }

  MACADDR=`ifconfig | awk '/ether/ {print $2}'`
  IFACE=`netstat -nr | awk '{if($3 ~ /^U$/) print $6}'`

  CONFFILE=`get_conf`

  if [ -n "$CONFFILE" ]; then
    sh $CONFFILE $IFACE
  fi


::

  # vi /var/pxeboot/root/01:23:45:67:89:ab.conf

  #!/bin/sh

  IFACE=$1
  DIST_TXZ=`ls /usr/freebsd-dist/*.txz`

  gpart destroy -F ada1
  gpart create -s gpt ada1
  gpart add -s 64K -t freebsd-boot ada1
  gpart add -s 8G -t freebsd-swap -l swap0 ada1
  gpart add -t freebsd-ufs ada1
  gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 ada1

  newfs -U /dev/ada1p3

  mount /dev/ada1p3 /mnt

  cd /mnt

  for FILE in $DIST_TXZ; do
    tar xfzp $FILE
  done

  cat << EOF > /mnt/tmp/freebsd_setup.sh
  newaliases
  tzsetup Asia/Tokyo
  printf "hogefugamoge" | pw usermod -n root -h 0
  dumpon /dev/ada1p2
  ln -sf /dev/ada1p2 /dev/dumpdev
  EOF

  cat << EOF > /mnt/etc/rc.conf
  hostname="hoge.local"
  keymap="us.iso.kbd"
  ifconfig_${IFACE}=" inet 192.168.0.252 netmask 255.255.255.0"
  defaultrouter="192.168.0.254"
  sshd_enable="YES"
  # Set dumpdev to "AUTO" to enable crash dumps, "NO" to disable
  dumpdev="AUTO"
  EOF

  cat << EOF > /mnt/etc/resolv.conf
  nameserver 8.8.8.8
  EOF

  cat << EOF > /mnt/etc/fstab
  # Device        Mountpoint      FStype  Options Dump    Pass#
  /dev/ada1p3     /               ufs     rw      1       1
  /dev/ada1p2     none            swap    sw      0       0
  EOF

  mount -t devfs dev /mnt/dev
  chroot /mnt /bin/sh /tmp/freebsd_setup.sh

  rm /mnt/tmp/freebsd_setup.sh
  cd /
  umount /mnt/dev
  umount /mnt
  reboot


* https://www.bsdconsulting.co.jp/CGI/BSDC.CGI?CNT=FREEBSDSTUDY_2013022201
* http://stefankonarski.de/content/freebsd-9-pxe-boot-und-bsdinstall-installieren
