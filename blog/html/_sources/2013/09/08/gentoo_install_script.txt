Gentoo Linux インストールスクリプト
===============================================================



.. author:: default
.. categories:: gentoo
.. tags:: gentoo
.. comments::


* 「そして私はOpenOfficeのビルドを諦めた」
* 「俺たちはなにと戦っているのだ...」

などの名言で知られる(私調べ)
Gentoo Linuxのインストールスクリプトを書いてみた。

* 「Gentoo LiveCD」を使わなくてもGentooはインストール出来るよ
* Gentooインストールまでの各種コマンドを間違いなく打ち込む自身がないよ
* Gentoo怖くないよ

などが今回のモチベーションである。

「 :doc:`../07/debian_wheezy_pxeboot` 」で構築した環境にスクリプトを配置する。

その他に、 `stage3`_ , `portage`_ , カーネルのコンフィグファイルをスクリプトのあるディレクトリに用意しておく。

実機,仮想環境(KVM)ともに動作確認は出来ている。
Gentooを複数台セットアップする予定はいまのところない。

::

  % cp /boot/config-* /var/scripts
  % cd /var/scripts
  % wget http://ftp.jaist.ac.jp/pub/Linux/Gentoo/snapshots/portage-20130830.tar.bz2
  % wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3/stage3-amd64-20130822.tar.bz2


::

  # vi /var/scripts/01:23:45:67:89:ab.conf

.. code-block:: bash

  #!/bin/bash -x

  DATETIME=`date +"%m%d%H%M%Y"`

  DISK="/dev/vda"
  IFACE=$1
  CHROOT_GENTOO="/mnt/$2"

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
  mkfs.ext3 ${DISK}2
  mkfs.ext3 ${DISK}6

  mount ${DISK}2 ${CHROOT_GENTOO}

  tar xvjf stage3-*.tar.bz2 -C ${CHROOT_GENTOO}
  tar xvjf portage-*.tar.bz2 -C ${CHROOT_GENTOO}/usr

  mount ${DISK}1 ${CHROOT_GENTOO}/boot
  mount ${DISK}6 ${CHROOT_GENTOO}/home

  mount --rbind /dev ${CHROOT_GENTOO}/dev
  mount -t proc none ${CHROOT_GENTOO}/proc
  mount --rbind /sys ${CHROOT_GENTOO}/sys

  cat << EOF > ${CHROOT_GENTOO}/etc/conf.d/hostname
  HOSTNAME="gentoo.localnet"
  EOF

  cat << EOF > ${CHROOT_GENTOO}/etc/conf.d/hwclock
  clock="local"
  EOF

  cat << EOF > ${CHROOT_GENTOO}/etc/conf.d/keymaps
  KEYMAP="us"
  EOF

  cp -L /etc/resolv.conf ${CHROOT_GENTOO}/etc

  cat << EOF > ${CHROOT_GENTOO}/etc/conf.d/net
  config_${IFACE}="192.168.2.251/24"
  routes_${IFACE}="default via 192.168.2.254"
  EOF

  cd ${CHROOT_GENTOO}/etc/init.d
  ln -s net.lo net.${IFACE}

  cat << EOF > ${CHROOT_GENTOO}/etc/fstab
  ${DISK}1               /boot           ext2            defaults        0 2
  ${DISK}2               /               ext3            defaults        0 1
  ${DISK}6               /home           ext3            defaults        0 2
  ${DISK}5               none            swap            sw              0 0
  EOF

  cat << EOF >> ${CHROOT_GENTOO}/etc/portage/make.conf
  SYNC="rsync://ftp.jaist.ac.jp/pub/Linux/Gentoo"
  GENTOO_MIRRORS="http://ftp.jaist.ac.jp/pub/Linux/Gentoo/ ftp://ftp.iij.ad.jp/pub/linux/gentoo/"
  EOF

  cp /var/scripts/config-* ${CHROOT_GENTOO}/root

  cat << EOF > ${CHROOT_GENTOO}/tmp/gentoo_setup.sh
  env-update
  source /etc/profile

  export CONFIG_PROTECT_MASK="/etc"

  cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  echo "Asia/Tokyo" > /etc/timezone
  date $DATETIME

  echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen

  emerge-webrsync

  emerge rsyslog vixie-cron
  rc-update add vixie-cron default
  rc-update add rsyslog default
  rc-update add sshd default
  rc-update add net.${IFACE} default

  emerge vim gentoo-sources

  cd /usr/src/linux
  cat <(egrep '(EXT2|EXT3|VIRTIO)' /root/config-* | sed 's/=m/=y/g') <(egrep -v '(EXT2|EXT3|VIRTIO)' /root/config-*) > .config

  echo n | make oldconfig
  make
  make modules_install
  make install

  emerge --autounmask-write grub:2
  emerge grub:2
  mkdir /boot/grub2
  grub2-mkconfig -o /boot/grub2/grub.cfg
  grub2-install --no-floppy --root-directory=/ $DISK

  grep -v rootfs /proc/mounts > /etc/mtab

  useradd -m -G wheel nanashi
  echo "nanashi:ebifuraibutsukenzo" | chpasswd
  echo "root:hogefugamoge" | chpasswd
  EOF

  chroot $CHROOT_GENTOO /bin/bash /tmp/gentoo_setup.sh

  rm ${CHROOT_GENTOO}/tmp/gentoo_setup.sh

  cd /
  umount -l ${CHROOT_GENTOO}/{boot,home,proc,dev,sys}
  umount -l $CHROOT_GENTOO
  sleep 2
  rmdir $CHROOT_GENTOO
  reboot


.. _stage3: http://www.gentoo.org/main/en/where.xml
.. _portage: http://ftp.jaist.ac.jp/pub/Linux/Gentoo/snapshots/

* http://d.hatena.ne.jp/meech/20120221/1329839829
* http://www.gentoo.org/doc/ja/handbook/handbook-amd64.xml?full=1

