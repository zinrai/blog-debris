schrootでaufsを使う
====================================================



.. author:: default
.. categories:: schroot
.. tags:: debian, wheezy, schroot, aufs
.. comments::

schroot(1)でaufsを使いたいなと思いschroot.conf(5)を眺めてみたところunion-type,union-mount-optionsというオプションを見付けた。
union-typeにaufsを指定し、union-mount-optionsにunion mountするときのオプションを書けばオプションをパースしてくれる。

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.4 (wheezy)
  Release:        7.4
  Codename:       wheezy

::

  % vi /etc/schroot/chroot.d/fuga.conf

  [fuga]
  type=directory
  directory=/var/chroot/fuga
  union-type=aufs
  union-mount-options=br:/var/chroot/fuga:/var/chroot/wheezy=ro none /var/chroot/fuga
  profile=fuga
  users=hoge
  root-groups=root
