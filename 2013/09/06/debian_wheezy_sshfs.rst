sshfs
======================================



.. author:: default
.. categories:: sshfs
.. tags:: debian, wheezy, sshfs
.. comments::


言わずと知れたSSH経由でリモートサーバのディレクトリをマウントしてくれるツール

いつも便利に使わせてもらっている。

::

  # apt-get instal sshfs

fuseグループに所属していないと「fuse: failed to open /dev/fuse: Permission denied」となる。

::

  # usermod -a -G fuse hoge

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.1 (wheezy)
  Release:        7.1
  Codename:       wheezy

::

  $ sshfs --version
  SSHFS version 2.4
  FUSE library version: 2.9.0
  using FUSE kernel interface version 7.18

::

  $ sshfs -p 18465 hoge@192.168.2.1:/home/hoge remote_dir
  $ fusermount -u remote_dir

* http://fuse.sourceforge.net/sshfs.html
