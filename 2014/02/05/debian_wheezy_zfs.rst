ZFS on Linux (Debian wheezy)
==================================



.. author:: default
.. categories:: debian, zfs
.. tags:: debian, wheezy, zfs
.. comments::

LinuxでもZFSがいい感じで動くという話を聞いたので使ってみた。

::

  % uname -a
  Linux hoge 3.2.0-4-amd64 #1 SMP Debian 3.2.51-1 x86_64 GNU/Linux

::

  % lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.3 (wheezy)
  Release:        7.3
  Codename:       wheezy

::

  % wget http://archive.zfsonlinux.org/debian/pool/main/z/zfsonlinux/zfsonlinux_2%7Ewheezy_all.deb
  % dpkg -i zfsonlinux_2~wheezy_all.deb
  % apt-get update
  % apt-get install debian-zfs

2TBのHDDをRAID1してみる。

::

  % parted /dev/sda -s "mklabel gpt"
  % parted /dev/sdc -s "mklabel gpt"

  % zpool create zfspool mirror sda sdc
  % zpool list -v
  NAME   SIZE  ALLOC   FREE    CAP  DEDUP  HEALTH  ALTROOT
  zfspool  1.81T   556K  1.81T     0%  1.00x  ONLINE  -
    mirror  1.81T   556K  1.81T         -
      sda      -      -      -         -
      sdc      -      -      -         -

::

  % zfs create zfspool/disk1
  % zfs list
  NAME            USED  AVAIL  REFER  MOUNTPOINT
  zfspool         692K  1.78T   136K  /zfspool
  zfspool/disk1   136K  1.78T   136K  /zfspool/disk1

ブロックデバイスとして見えたらKVMのGuestOS用のディスクとして使えると思うので、その辺を調べてみる。

* http://zfsonlinux.org/debian.html
* http://sourceforge.jp/magazine/13/04/01/133000
