aufsを使ったchroot環境
===========================================================================



.. author:: default
.. categories:: debian
.. tags:: debian, chroot, aufs
.. comments::


aufsとはLinuxにおけるunion mountの実装の1つである。
union mountとは複数のファイルシステムを重ね合わせ一つのファイルシステムに見せる機能である。
この機能はchroot環境と組み合わせると非常に勝手がいい。
chroot環境をリードオンリーにし書き込み用のディレクトリと重ね合わせることで
chroot環境を汚すことなく使うことができるようになる。


::

  % lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.1 (wheezy)
  Release:        7.1
  Codename:       wheezy


::

  % modinfo aufs
  filename:       /lib/modules/3.2.0-4-amd64/kernel/fs/aufs/aufs.ko
  staging:        Y
  version:        3.2-20130204
  description:    aufs -- Advanced multi layered unification filesystem
  author:         Junjiro R. Okajima <aufs-users@lists.sourceforge.net>
  license:        GPL
  srcversion:     523C2808903A77806346A06
  depends:
  intree:         Y
  vermagic:       3.2.0-4-amd64 SMP mod_unload modversions
  parm:           brs:use <sysfs>/fs/aufs/si_*/brN (int)


::

  % modprobe aufs


::

  % debootstrap stable /hoge/wheezy http://ftp.jp.debian.org/debian


::

  % mount -t aufs -o br:/hoge/rails:/hoge/wheezy=ro none /hoge/rails
  % mount --rbind /dev /hoge/aufs_dir/dev
  % mount -t proc none /hoge/aufs_dir/proc
  % mount --rbind /sys /hoge/aufs_dir/sys
  % chroot /hoge/aufs_dir /bin/bash

重ねるディレクトリを変えることで簡単にchroot環境を切り替えられる。

起動時にaufsを有効にしたければmodules(5)に書いておく。

::

  % vi /etc/modules
  aufs


.. _aufs: http://aufs.sourceforge.net/
.. _LVM: http://ja.wikipedia.org/wiki/論理ボリュームマネージャ


* http://aufs.sourceforge.net/
