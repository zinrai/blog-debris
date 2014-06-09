Debian wheezy NFSv4 Client
====================================================



.. author:: default
.. categories:: nfs
.. tags:: debian, wheezy, nfs
.. comments::

:doc:`NFS Server <../08/freebsd_nfsv4_server>` を構築したので、ClientからServerへ接続してみる。

::

  % uname -a
  Linux zinrai 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2 x86_64 GNU/Linux

  % cat /etc/debian_version
  7.5

::

  % apt-get install nfs-common

  % service nfs-common status
  all daemons running

  % service nfs-common start
  % service nfs-common stop

mount(8)
--------------------

::

  % mount -t nfs4 192.168.0.1:/mnt/nfs /home/zinrai/nfs

fstab(5)
--------------------

nfs(5)を眺めながらfstab(5)を設定してみる。

::

  % vi /etc/fstab
  192.168.0.1:/mnt/nfs /home/zinrai/nfs nfs4 rw 0 0

  % mount -a
  % umount /home/zinrai/nfs

