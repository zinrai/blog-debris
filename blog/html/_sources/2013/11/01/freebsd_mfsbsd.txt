virtioを組み込んだmfsBSDイメージ作成
========================================================


.. author:: default
.. categories:: mfsbsd
.. tags:: freebsd, mfsbsd
.. comments::


「 :doc:`../..//07/20/freebsd_pxeboot` 」だとFreeBSD母艦が必要になるので、
どうにかして `Syslinux`_ にまとめられないか調べてみたところ `mfsBSD`_ というものを見付けた。
今回は「9.1-RELEASE」のmfsBSDを作成した。

mfsBSDイメージ作成
------------------------------

::

  % fetch http://mfsbsd.vx.sk/release/mfsbsd-2.1.tar.gz
  % tar zvxf mfsbsd-2.1.tar.gz
  % cd mfsbsd-2.1/conf
  % cp rc.conf.sample rc.conf
  % cp rc.local.sample rc.local
  % cp loader.conf.sample loader.conf
  % cd ..
  % mkdir freebsd91
  % cd freebsd91
  % fetch http://ftp.jaist.ac.jp/pub/FreeBSD/releases/amd64/9.1-RELEASE/base.txz
  % fetch http://ftp.jaist.ac.jp/pub/FreeBSD/releases/amd64/9.1-RELEASE/kernel.txz
  % cd ..
  % make RELEASE=9.1-RELEASE BASE=/path/freebsd91

  % ls *.img
  mfsbsd-9.1-RELEASE-amd64.img

`mfsBSD`_ のMakefileを眺めてみると「RELEASE」オプションを付けない場合、
生成されるイメージファイル名にuname(1)が使われる。
「RELEASE」オプションを付けてないとホストが「9.2-RELEASE」「10-CURRENT」のとき
「9.1-RELEASE」のイメージファイルを作成するとホストのversionの付いたファイル名で
イメージファイルが生成される。

VirtIOを有効にしている仮想環境でも `mfsBSD`_ を使えるようにしてみる。
VirtIOのバイナリを作るのが面倒だったので配布されていないか調べてみたら見付けた。

::

  % mkdir virtio
  % cd virtio
  % fetch http://people.freebsd.org/~kuriyama/virtio/9.1/virtio-kmod-9.1-0.250249.tbz
  % tar Jxf virtio-kmod-9.1-0.250249.tbz

「BOOTMODULES」変数にモジュールをスペース区切り書いておけば
イメージファイル作成時にモジュールが組込まれる。
VirtIOモジュールのほうはkernel.txzを展開し、
boot/kernelにコピーして再度圧縮しておく。

::

  % cd /path/freebsd91
  % tar zxpf kernel.txz

  % cd /path/virtio/boot/modules
  % cp `ls` /path/freebsd91/boot/kernel

  % cd /path/freebsd91
  % tar Jcvf kernel.txz boot


::

  % diff -u Makefile Makefile.org
  --- Makefile    2013-11-01 12:43:34.000000000 +0900
  +++ Makefile.org        2013-11-01 01:34:12.000000000 +0900
  @@ -73,7 +73,7 @@
   #
   DOFS=${TOOLSDIR}/doFS.sh
   SCRIPTS=mdinit mfsbsd interfaces packages
  -BOOTMODULES=acpi ahci virtio virtio_pci virtio_blk virtio_balloon if_vtnet
  +BOOTMODULES=acpi ahci
   MFSMODULES=geom_mirror geom_nop opensolaris zfs ext2fs snp smbus ipmi ntfs nullfs tmpfs
   #

Syslinux
------------------------------

* :doc:`../../10/24/debian_wheezy_dnsmasq_proxy_dhcp`
* :doc:`../../10/26/centos_diskless`

これでDebian,CentOS,FreeBSDのディスクレスブート環境が出来上がった。

::

  % vi /path/pxelinux.cfg/default

  default menu.c32
  label FreeBSD 9.1
  kernel memdisk
  append initrd=mfsbsd-9.1-RELEASE-amd64.img harddisk

9.2-RELEASEからVirtIOは標準で入っている。
VirtIOを使いたければ、設定をloader.confに書くだけ。
シェルスクリプトには下記のような変更を加えておけばいい。

::

  % diff -u freebsd_install.conf freebsd_virtio.conf
  --- freebsd_install.conf        2013-11-01 18:05:26.993246593 +0900
  +++ freebsd_virtio.conf 2013-11-01 17:48:52.725299517 +0900
  @@ -1,8 +1,8 @@
   #!/bin/sh -x

  -# 01:23:45:67:89:ab
  +# 01:23:45:67:89:cd

  -DISK=ada0
  +DISK=vtbd0
   IFACE=$1
   CWD=$2
   CHROOT_FREEBSD="/mnt/$3"
  @@ -27,8 +27,16 @@
     tar xfzp $FILE
   done

  +cat << EOF > ${CHROOT_FREEBSD}/boot/loader.conf
  +virtio_load="YES"
  +virtio_pci_load="YES"
  +virtio_blk_load="YES"
  +if_vtnet_load="YES"
  +virtio_balloon_load="YES"
  +EOF
  +
   cat << EOF > ${CHROOT_FREEBSD}/etc/rc.conf
  -hostname="freebsd-install.local"
  +hostname="freebsd-virtio.local"
   keymap="us.iso.kbd"
   ifconfig_${IFACE}=" inet 192.168.2.200 netmask 255.255.255.0"
   defaultrouter="192.168.2.254"

.. _mfsBSD: http://mfsbsd.vx.sk/
.. _Syslinux: http://www.syslinux.org/wiki/index.php/The_Syslinux_Project

* http://mfsbsd.vx.sk/
* http://people.freebsd.org/~kuriyama/virtio/
