PXE boot + シェルスクリプトでFreeBSD 9.1のインストール自動化
###############################################################


.. author:: default
.. categories:: freebsd, pxeboot
.. tags:: freebsd, pxeboot
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
  /var/pxeboot -alldirs -maproot=root

  # /etc/rc.d/nfsd onestart

再起動後もデーモンを起動させておきたければrc.confに書いておく。

::

  # vi /etc/rc.conf
  inetd_enable="YES"
  dhcpd_enable="YES"
  nfs_server_enable="YES"

FreeBSDインストールスクリプト
***************************************************************


このシェルスクリプトはPXE bootしたマシンのMACアドレスを見てマッチした
[MACアドレス].confファイルに書かれたシェルスクリプトを実行するようになっている。

::

  # vi /var/pxeboot/var/scripts/os_install.sh

.. literalinclude:: os_install.sh
   :language: bash

::

  # vi /var/pxeboot/var/scripts/01:23:45:67:89:ab.conf

  #!/bin/sh

  IFACE=$1
  DISK=ada1
  MOUNTDIR="/mnt/$2"
  DIST_TXZ=`ls /usr/freebsd-dist/*.txz`

  gpart destroy -F $DISK
  gpart create -s gpt $DISK
  gpart add -s 64K -t freebsd-boot $DISK
  gpart add -s 8G -t freebsd-swap -l swap0 $DISK
  gpart add -t freebsd-ufs $DISK
  gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 $DISK

  newfs -U /dev/${DISK}p3

  mount /dev/${DISK}p3 $MOUNTDIR

  cd $MOUNTDIR

  for FILE in $DIST_TXZ; do
    tar xfzp $FILE
  done

  cat << EOF > ${MOUNTDIR}/etc/rc.conf
  hostname="freebsd.local"
  keymap="us.iso.kbd"
  ifconfig_${IFACE}=" inet 192.168.0.252 netmask 255.255.255.0"
  defaultrouter="192.168.0.254"
  sshd_enable="YES"
  # Set dumpdev to "AUTO" to enable crash dumps, "NO" to disable
  dumpdev="AUTO"
  EOF

  cat << EOF > ${MOUNTDIR}/etc/resolv.conf
  nameserver 8.8.8.8
  EOF

  cat << EOF > ${MOUNTDIR}/etc/fstab
  # Device        Mountpoint      FStype  Options Dump    Pass#
  /dev/${DISK}p3     /               ufs     rw      1       1
  /dev/${DISK}p2     none            swap    sw      0       0
  EOF

  cat << EOF > ${MOUNTDIR}/tmp/freebsd_setup.sh
  newaliases
  touch /etc/wall_cmos_clock
  tzsetup Asia/Tokyo

  printf "hogefugamoge" | pw usermod -n root -h 0

  pw useradd -n nanashi -s /bin/tcsh -G wheel -m
  printf "ebifuraibutsukenzo" | pw usermod -n nanashi -h 0

  dumpon /dev/${DISK}p2
  ln -sf /dev/${DISK}p2 /dev/dumpdev
  EOF

  mount -t devfs dev ${MOUNTDIR}/dev
  chroot $MOUNTDIR /bin/sh /tmp/freebsd_setup.sh

  rm ${MOUNTDIR}/tmp/freebsd_setup.sh

  cd /
  umount ${MOUNTDIR}/dev
  umount $MOUNTDIR

  rmdir $MOUNTDIR
  reboot


PXE boot時に指定のスクリプトを実行するようにrc.localに書いておく。

::

  # vi /var/pxeboot/etc/rc.local

  #!/bin/sh
  # $FreeBSD: release/9.1.0/release/rc.local 232427 2012-03-03 02:13:53Z nwhitehorn $

  /var/script/os_install.sh

* https://www.bsdconsulting.co.jp/CGI/BSDC.CGI?CNT=FREEBSDSTUDY_2013022201
* http://stefankonarski.de/content/freebsd-9-pxe-boot-und-bsdinstall-installieren
