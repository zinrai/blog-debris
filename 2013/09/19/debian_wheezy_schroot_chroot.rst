schrootを使って一般ユーザでchroot
========================================================



.. author:: default
.. categories:: schroot
.. tags:: schroot, chroot, debian, wheezy
.. comments::


schrootはroot権限を持たない一般ユーザでもchrootできるようにするwrapperである。
オプションや設定ひとつでホストの環境,環境変数を引き継ぐことができとても便利なツールだ。

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.1 (wheezy)
  Release:        7.1
  Codename:       wheezy

::

  % apt-get install schroot


::

  % schroot --version
  schroot (Debian sbuild) 1.6.4 (26 Oct 2012)
  Written by Roger Leigh

  Copyright © 2004–2012 Roger Leigh
  This is free software; see the source for copying conditions.  There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  Configured features:
    DEVLOCK      Device locking
    PAM          Pluggable Authentication Modules
    PERSONALITY  Linux kernel Application Binary Interface switching
    UNION        Support for filesystem unioning

  Available chroot types:
    BLOCKDEV     Support for ‘block-device’ chroots
    BTRFSSNAP    Support for ‘btrfs-snapshot’ chroots
    CUSTOM       Support for ‘custom’ chroots
    DIRECTORY    Support for ‘directory’ chroots
    FILE         Support for ‘file’ chroots
    LOOPBACK     Support for ‘loopback’ chroots
    LVMSNAP      Support for ‘lvm-snapshot’ chroots
    PLAIN        Support for ‘plain’ chroots

::

  $ mkdir -p /var/chroot/wheezy
  % debootstrap stable /var/chroot/wheezy http://ftp.jp.debian.org/debian


::

  % find /etc/schroot
  /etc/schroot
  /etc/schroot/buildd
  /etc/schroot/buildd/nssdatabases
  /etc/schroot/buildd/copyfiles
  /etc/schroot/buildd/fstab
  /etc/schroot/desktop
  /etc/schroot/desktop/nssdatabases
  /etc/schroot/desktop/copyfiles
  /etc/schroot/desktop/fstab
  /etc/schroot/default
  /etc/schroot/default/nssdatabases
  /etc/schroot/default/copyfiles
  /etc/schroot/default/fstab
  /etc/schroot/setup.d
  /etc/schroot/setup.d/05file
  /etc/schroot/setup.d/00check
  /etc/schroot/setup.d/70services
  /etc/schroot/setup.d/50chrootname
  /etc/schroot/setup.d/15killprocs
  /etc/schroot/setup.d/99check
  /etc/schroot/setup.d/15binfmt
  /etc/schroot/setup.d/05lvm
  /etc/schroot/setup.d/05btrfs
  /etc/schroot/setup.d/05union
  /etc/schroot/setup.d/10mount
  /etc/schroot/setup.d/20copyfiles
  /etc/schroot/setup.d/20nssdatabases
  /etc/schroot/minimal
  /etc/schroot/minimal/nssdatabases
  /etc/schroot/minimal/copyfiles
  /etc/schroot/minimal/fstab
  /etc/schroot/sbuild
  /etc/schroot/sbuild/nssdatabases
  /etc/schroot/sbuild/copyfiles
  /etc/schroot/sbuild/fstab
  /etc/schroot/chroot.d
  /etc/schroot/schroot.conf

ホストのfstabにschroot用の設定を書いていたり、
ホストのfstabに設定を書くのがイケてないと言っている記事を見掛けるが、
schroot(1),schroot.conf(5)を眺めたのだろうか。
/etc/schroot以下の構成は上記のようになっている。
ホストからchroot環境へコピーするファイル(passwd,resolv.confなど)やマウントするディレクトリ
の設定などは/etc/schroot以下にディレクトリを切り設定ファイルを書いていく(このディレクトリをプロファイルと呼ぶことにする)。
下記はdefaultプロファイルの設定ファイルである。


::

  $ cat /etc/schroot/default/copyfiles
  # Files to copy into the chroot from the host system.
  #
  # <source and destination>
  /etc/resolv.conf

::

  $ cat /etc/schroot/default/nssdatabases
  # System databases to copy into the chroot from the host system.
  #
  # <database name>
  passwd
  shadow
  group
  gshadow
  services
  protocols
  networks
  hosts

::

  $ cat /etc/schroot/default/fstab
  # fstab: static file system information for chroots.
  # Note that the mount point will be prefixed by the chroot path
  # (CHROOT_PATH)
  #
  # <file system> <mount point>   <type>  <options>       <dump>  <pass>
  /proc           /proc           none    rw,bind        0       0
  /sys            /sys            none    rw,bind        0       0
  /dev            /dev            none    rw,bind         0       0
  /dev/pts        /dev/pts        none    rw,bind         0       0
  /home           /home           none    rw,bind         0       0
  /tmp            /tmp            none    rw,bind         0       0

  # It may be desirable to have access to /run, especially if you wish
  # to run additional services in the chroot.  However, note that this
  # may potentially cause undesirable behaviour on upgrades, such as
  # killing services on the host.
  #/run           /run            none    rw,bind         0       0
  #/run/lock      /run/lock       none    rw,bind         0       0
  #/dev/shm       /dev/shm        none    rw,bind         0       0
  #/run/shm       /run/shm        none    rw,bind         0       0

プロファイルはprofileオプションを使い呼び出す。
デフォルトではdefaultプロファイルが呼び出される。

::

  % vi /etc/schroot/chroot.d/wheezy.conf
  [wheezy]
  type=directory
  directory=/var/chroot/wheezy
  profile=desktop
  users=zinrai
  root-groups=root


環境変数を引き継ぐ場合は「-p」オプションを付ける。

::

  $ schroot -c wheezy -p bash

* https://wiki.debian.org/Schroot
