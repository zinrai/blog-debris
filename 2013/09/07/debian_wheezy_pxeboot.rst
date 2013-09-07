PXE boot + シェルスクリプトでDebian Wheezyのインストール自動化
==========================================================================



.. author:: default
.. categories:: debian, pxeboot
.. tags:: debian, wheezy, pexboot, debootstrap, dnsmasq
.. comments::


みなさん、Debianのインストール作業はどうやっているだろうか。
私は、OSのインストール作業なんてお金を貰わない限り手動でやりたくないので自動化している。
OSの手動インストールをするだけでお金が発生するのであれば喜んでやらせていただく所存である。
RedHat系の「 `Kickstart`_ 」と同じような仕組みの「 `preseed`_ 」というものがDebianにも存在するが、
これを使わずに「pxeboot + debootstrap + シェルスクリプト」でインストールの自動化をしている。

pxeboot
---------------------

::

  # apt-get install debootstrap syslinux dnsmasq nfs-kernel-server


dnsmasq
#####################

DNSサーバ以外にもDHCP,TFTPサーバとしても使える便利なdnsmasq

::

  # vi /etc/dnsmasq.d/pxe.conf
  enable-tftp
  tftp-root=/var/lib/tftpboot
  dhcp-range=192.168.2.200,192.168.2.250,2h
  dhcp-option=3,192.168.2.254
  dhcp-boot=pxelinux.0


NFS
#####################

::

  # vi /etc/exports
  /var/lib/tftpboot/wheezy 192.168.2.0/24(rw,no_root_squash,no_subtree_check)



debootstrap
#####################

::

  # mkdir -p /var/lib/tftpboot/wheezy
  # debootstrap stable /var/lib/tftpboot/wheezy http://ftp.jp.debian.org/debian
  # chroot /var/lib/tftpboot/wheezy/ apt-get install linux-image-`uname -r` parted build-essential bzip2 debootstrap


syslinux
#####################

::

  # cp /boot/initrd* /var/lib/tftpboot
  # cp /boot/vmlinuz* /var/lib/tftpboot

  # cp /usr/lib/syslinux/pxelinux.0 /var/lib/tftpboot
  # mkdir /var/lib/tftpboot/pxelinux.cfg

  # vi /var/lib/tftpboot/pxelinux.cfg/default
  default Debian
  prompt 1
  timeout 10
  label Debian
  kernel vmlinuz-3.2.0-4-amd64
  append initrd=initrd.img-3.2.0-4-amd64 root=/dev/nfs ip=dhcp nfsroot=192.168.2.253:/var/lib/tftpboot/wheezy ro single


::

  # service dnsmasq start
  # service nfs-kernel-server start

Debianインストールスクリプト
----------------------------------------

仕組みは「 :doc:`../../07/20/freebsd_pxeboot` 」と同じである。

debootstrapで取得した最小構成のWheezyをコピーするスクリプトを書いただけ。

grub2のインストール時にブートローダをどのディスクにインストールするかを設定するダイアログが出てきてしまうので
「DEBIAN_FRONTEND=noninteractive」を環境変数として設定しダイアログを出さないのがポイントである。

代わりにダイアログで実行されるコマンドをスクリプト内で実行する。

この環境変数は解決方法はないかとdebconf(1)を眺めていたら

::

  Debconf is a configuration system for Debian packages. For a debconf overview and documentation for sysadmins, see debconf(7) (in the debconf-doc package).

書かれており、説明に従いdebconf-docをインストールし、debconf(7)を眺めたところ見付けた。

::

  # mkdir -p /var/scripts/wheezy
  # debootstrap stable /var/scripts/wheezy http://ftp.jp/debian.org/debian


::

  # vi /var/scripts/os_install.sh

.. literalinclude:: ../../07/20/os_install.sh
   :language: bash


::

  # vi /var/scripts/01:23:45:67:89:ab.conf


::

  #!/bin/bash -x

  DISK="/dev/vda"
  IFACE=$1
  CHROOT_DEBIAN="/mnt/$2"

  dd if=/dev/zero of=$DISK bs=1024 count=1

  parted $DISK -s 'mklabel msdos'
  parted $DISK -s 'mkpart primary 1 500'
  parted $DISK -s 'mkpart primary 501 35000'
  parted $DISK -s 'mkpart extended 35001 -0'
  parted $DISK -s 'mkpart logical 35001 38000'
  parted $DISK -s 'mkpart logical 38001 -0'
  parted $DISK -s 'set 1 boot on'

  mkswap ${DISK}5
  swapon ${DISK}5
  mkfs.ext2 ${DISK}1
  mkfs.ext4 ${DISK}2
  mkfs.ext4 ${DISK}6

  mount ${DISK}2 ${CHROOT_DEBIAN}

  cp -Rp wheezy/* $CHROOT_DEBIAN

  mount ${DISK}1 ${CHROOT_DEBIAN}/boot
  mount ${DISK}6 ${CHROOT_DEBIAN}/home

  mount --rbind /dev ${CHROOT_DEBIAN}/dev
  mount -t proc none ${CHROOT_DEBIAN}/proc
  mount --rbind /sys ${CHROOT_DEBIAN}/sys

  cat << EOF > ${CHROOT_DEBIAN}/etc/hostname
  install.localnet
  EOF


  cat << EOF > ${CHROOT_DEBIAN}/etc/resolv.conf
  nameserver 8.8.8.8
  EOF

  cat << EOF > ${CHROOT_DEBIAN}/etc/network/interfaces
  auto lo
  iface lo inet loopback

  auto eth0
  iface eth0 inet static
  address  192.168.2.100
  netmask 255.255.255.0
  gateway 192.168.2.254
  EOF

  cat << EOF > ${CHROOT_DEBIAN}/etc/fstab
  ${DISK}1               /boot           ext2            defaults        0 2
  ${DISK}2               /               ext4            defaults        0 1
  ${DISK}6               /home           ext4            defaults        0 2
  ${DISK}5               none            swap            sw              0 0
  EOF


  cat << EOF > ${CHROOT_DEBIAN}/tmp/debian_setup.sh
  #!/bin/bash

  export DEBIAN_FRONTEND=noninteractive
  cp /usr/local/share/zoneinfo/Asia/Tokyo /etc/localtime

  apt-get install -y linux-image-`uname -r` grub2 openssh-server

  grub-mkconfig -o /boot/grub/grub.cfg
  grub-install --no-floppy --root-directory=/ $DISK

  grep -v rootfs /proc/mounts > /etc/mtab

  useradd -m -G sudo nanashi
  echo "nanashi:ebifuraibutsukenzo" | chpasswd
  echo "root:hogefugamoge" | chpasswd
  EOF

  chroot ${CHROOT_DEBIAN} /bin/bash /tmp/debian_setup.sh

  rm ${CHROOT_DEBIAN}/tmp/debian_setup.sh

  cd /
  umount -l ${CHROOT_DEBIAN}/{boot,home,proc,dev,sys}
  umount -l $CHROOT_DEBIAN
  sleep 2
  rmdir $CHROOT_DEBIAN
  reboot

pxeboot時にインストールスクリプトが実行されるようrc.localに書いておく。

::

  # vi /var/lib/tftpboot/wheezy/etc/rc.local

  #!/bin/sh -e
  #
  # rc.local
  #
  # This script is executed at the end of each multiuser runlevel.
  # Make sure that the script will "exit 0" on success or any other
  # value on error.
  #
  # In order to enable or disable this script just change the execution
  # bits.
  #
  # By default this script does nothing.

  /var/scripts/os_install.sh

  exit 0

.. _preseed: http://www.debian.org/releases/stable/amd64/apb.html.ja
.. _Kickstart: http://fedoraproject.org/wiki/Anaconda/Kickstart

* http://fedoraproject.org/wiki/Anaconda/Kickstart
* http://www.debian.org/releases/stable/amd64/apb.html.ja
