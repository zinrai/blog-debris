シェルスクリプトでFreeBSD 9.1のインストール自動化
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
  server-name "pxeboot";            # name of the tftp-server
  server-identifier 192.168.0.253;  # address of the tftp-server
  next-server 192.168.0.253;        # address of the NFS-server

  subnet 192.168.0.0 netmask 255.255.255.0 {
      range 192.168.0.220 192.168.0.250;
      option routers 192.168.0.254;
      option root-path "/var/pxeboot"; # root-path for NFS
      filename "pxeboot";              # filename of NBP (network bootstrap program)
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
  dhcpd_ifaces="em0"
  nfs_server_enable="YES"

FreeBSDインストールスクリプト
***************************************************************

PXE BootしたマシンのMACアドレスが書かれたシェルスクリプトを探し、実行するようになっている。

::

  # mkdir /var/scripts/freebsd91
  # cd /usr/freebsd-dist
  # cp *.txz /var/scripts/freebsd91

::

  # vi /var/pxeboot/var/scripts/os_install.sh

.. literalinclude:: os_install.sh
   :language: bash

::

  # vi /var/pxeboot/var/scripts/freebsd_install.conf

.. literalinclude:: freebsd_install.conf
   :language: bash


PXE boot時に指定のスクリプトを実行するようにrc.localに書いておく。

::

  # vi /var/pxeboot/etc/rc.local

  #!/bin/sh
  # $FreeBSD: release/9.1.0/release/rc.local 232427 2012-03-03 02:13:53Z nwhitehorn $

  /var/script/os_install.sh

* https://www.bsdconsulting.co.jp/CGI/BSDC.CGI?CNT=FREEBSDSTUDY_2013022201
* http://stefankonarski.de/content/freebsd-9-pxe-boot-und-bsdinstall-installieren
