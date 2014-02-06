KVMのGuestOSにZVOLを使う
==========================================



.. author:: default
.. categories:: debian
.. tags:: debian, wheezy, kvm, zfs
.. comments::

「 :doc:`../05/debian_wheezy_zfs` 」で最後に書いたブロックデバイスとして見えないかを調べてみた。

ZVOL
------------------------------

ZFSの領域をブロックデバイスとして切り出すことができる機能

::

  % zfs create -V 20G zfspool/disk2
  % zfs list
  NAME            USED  AVAIL  REFER  MOUNTPOINT
  zfspool        22.2G  1.76T   144K  /zfspool
  zfspool/disk1   136K  1.76T   136K  /zfspool/disk1
  zfspool/disk2  20.6G  1.78T    72K  -

  % ls -l /dev/zvol/zfspool/
  total 0
  lrwxrwxrwx 1 root root 10 Feb  6 12:37 disk2 -> ../../zd16

sparse volume
------------------------------

上記だと20GBの領域がまるまる割り当てられてしまうので、thin provisioning的な機能はないかzfs(8)を眺めてみた。

man zfsして「thin provisioning」で検索して「 "sparse volume" (also known as "thin provisioning")」の文の見付けて「sparse volume」で検索したらオプションを探し当てることができた。

::

  Though not recommended, a "sparse volume" (also known as "thin provisioning") can be created by specifying the -s option to the  zfs  create  -V command,  or by changing the reservation after the volume has been created. A "sparse volume" is a volume where the reservation is less then the volume size. Consequently, writes to a sparse volume can fail with ENOSPC when the pool is low on space. For a sparse volume, changes to volsize are not reflected in the reservation.

::

  -s

  Creates a sparse volume with no reservation. See volsize in the Native Properties section for more information about sparse volumes.

::

  % zfs create -s -V 50G zfspool/kvm1
  % zfs get all zfspool/kvm1
  NAME          PROPERTY              VALUE                  SOURCE
  zfspool/kvm1  type                  volume                 -
  zfspool/kvm1  creation              Thu Feb  6  1:13 2014  -
  zfspool/kvm1  used                  1.57G                  -
  zfspool/kvm1  available             1.76T                  -
  zfspool/kvm1  referenced            1.57G                  -
  zfspool/kvm1  compressratio         1.00x                  -
  zfspool/kvm1  reservation           none                   default
  zfspool/kvm1  volsize               50G                    local
  zfspool/kvm1  volblocksize          8K                     -
  zfspool/kvm1  checksum              on                     default
  zfspool/kvm1  compression           off                    default
  zfspool/kvm1  readonly              off                    default
  zfspool/kvm1  copies                1                      default
  zfspool/kvm1  refreservation        none                   default
  zfspool/kvm1  primarycache          all                    default
  zfspool/kvm1  secondarycache        all                    default
  zfspool/kvm1  usedbysnapshots       8K                     -
  zfspool/kvm1  usedbydataset         1.57G                  -
  zfspool/kvm1  usedbychildren        0                      -
  zfspool/kvm1  usedbyrefreservation  0                      -
  zfspool/kvm1  logbias               latency                default
  zfspool/kvm1  dedup                 off                    default
  zfspool/kvm1  mlslabel              none                   default
  zfspool/kvm1  sync                  standard               default
  zfspool/kvm1  refcompressratio      1.00x                  -
  zfspool/kvm1  written               8K                     -
  zfspool/kvm1  snapdev               hidden                 default

KVM
------------------------------

ZVOLをKVMのGuestOSに使ってみる。

::

  % apt-get install kvm virtinst virt-manager
  % brctl addbr br1
  % brctl addif br1 eth1
  % ifconfig eth1 up
  % ifconfig br1 up

.. code-block:: bash

  #!/bin/bash

  VM_NAME=$1
  MEM=$2
  IFACE=$3
  OS=$4

  DISKIMAGE="/dev/zvol/zfspool/$VM_NAME"

  if [ "$OS" = "centos" ]; then
    # CentOS 6.4 amd64
    DIST='http://ftp.jaist.ac.jp/pub/Linux/CentOS/6.4/os/x86_64/'
  elif [ "$OS" = "precise" ]; then
    # Ubuntu 12.04 amd64
    DIST='http://ftp.riken.jp/Linux/ubuntu/dists/precise/main/installer-amd64/'
  elif [ "$OS" = "squeeze" ]; then
    # Debian Squeeze amd64
    DIST='http://ftp.jp.debian.org/debian/dists/squeeze/main/installer-amd64/'
  elif [ "$OS" = "wheezy" ]; then
    # Debian Wheezy amd64
    DIST='http://ftp.jp.debian.org/debian/dists/wheezy/main/installer-amd64/'
  fi

  virt-install --hvm --accelerate --nographics \
    --name $VM_NAME \
    --network bridge=$IFACE,model=virtio \
    --ram $MEM \
    --vcpus 1 \
    --cpu core2duo \
    --os-type linux \
    --location $DIST \
    --disk path=$DISKIMAGE,bus=virtio \
    --extra-args='console=tty0 console=ttyS0,115200n8'

::

  % vm-install.sh kvm1 1024 br1 wheezy

  % ls -l /dev/zvol/zfspool/
  total 0
  lrwxrwxrwx 1 root root 10 Feb  6 12:37 disk2 -> ../../zd16
  lrwxrwxrwx 1 root root  9 Feb  6 12:12 kvm1 -> ../../zd0
  lrwxrwxrwx 1 root root 11 Feb  6 12:12 kvm1-part1 -> ../../zd0p1
  lrwxrwxrwx 1 root root 11 Feb  6 12:12 kvm1-part2 -> ../../zd0p2
  lrwxrwxrwx 1 root root 11 Feb  6 12:12 kvm1-part5 -> ../../zd0p5

ZFSでスナップショットをとったりロールバックできる環境が出来上がった。
LVM2やqemu-img(1)とおさらばヒャッハー。
GuestOSを停止しないでロールバックしようとすると「devide busy」と怒られる。

::

  % zfs snapshot zfspool/kvm1@snap1
  % zfs list -t snapshot
  NAME                 USED  AVAIL  REFER  MOUNTPOINT
  zfspool/kvm1@snap1   600K      -  1.57G  -

  % zfs rollback zfspool/kvm1@snap1

* https://pthree.org/2012/12/21/zfs-administration-part-xiv-zvols/
