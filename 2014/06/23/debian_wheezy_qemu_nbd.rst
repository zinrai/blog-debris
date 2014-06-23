qemu-nbd を使ってディスクイメージをマウントする
=========================================================



.. author:: default
.. categories:: qemu
.. tags:: debian, wheezy, qemu
.. comments::

KVMで使っているqcow2ディスクイメージをqemu-nbd(8)でマウントしてみる。

::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2

  $ cat /etc/debian_version
  7.5

::

  $ modinfo nbd
  filename:       /lib/modules/3.2.0-4-amd64/kernel/drivers/block/nbd.ko
  license:        GPL
  description:    Network Block Device
  depends:
  intree:         Y
  vermagic:       3.2.0-4-amd64 SMP mod_unload modversions
  parm:           nbds_max:number of network block devices to initialize (default: 16) (int)
  parm:           max_part:number of partitions per device (default: 0) (int)
  parm:           debugflags:flags for controlling debug output (int)

::

  % modprobe nbd max_part=16
  % qemu-nbd -c /dev/nbd0 test.qcow2

::

  % fdisk -l /dev/nbd0
  Disk /dev/nbd0: 214.7 GB, 214748364800 bytes
  255 heads, 63 sectors/track, 26108 cylinders, total 419430400 sectors
  Units = sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disk identifier: 0x000da898

       Device Boot      Start         End      Blocks   Id  System
  /dev/nbd0p1   *        2048   415238143   207618048   83  Linux
  /dev/nbd0p2       415240190   419428351     2094081    5  Extended
  /dev/nbd0p5       415240192   419428351     2094080   82  Linux swap / Solaris

::

  % mount /dev/nbp0p1 /mnt
  $ ls /mnt
  bin  boot  dev  etc  home  initrd.img  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  selinux  srv  sys  tmp  usr  var  vmlinuz
  % umount /mnt

::

  % qemu-nbd -d /dev/nbd0
  /dev/nbd0 disconnected
