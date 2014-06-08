FreeBSD 10 NFSv4 Server
========================================



.. author:: default
.. categories:: nfs
.. tags:: freebsd, nfs
.. comments::

FreeBSDでNFSv4サーバを構築してみる。nfsv4(4),exports(5)を眺めながら構築してみた。

::

  $ uname -a
  FreeBSD zinrai.localnet 10.0-RELEASE-p3 FreeBSD 10.0-RELEASE-p3 #0: Tue May 13 18:31:10 UTC 2014     root@amd64-builder.daemonology.net:/usr/obj/usr/src/sys/GENERIC  amd64

::

  % vi /etc/rc.conf
  nfs_server_enable="YES"
  nfsv4_server_enable="YES"
  nfsuserd_enable="YES"
  nfsd_enable="YES"
  rpcbind_enable="YES"
  mountd_enable="YES"
  # NFSv3
  rpc_statd_enable="YES"
  rpc_lockd_enable="YES"

nfsv4(4)にはnfs_server_enable,nfsv4_server_enable,nfsuserd_enableをrc.conf(5)に設定するよう書かれている。
/etc/rc.dディレクトリでnfs_server_enableをgrepしするとnfdsがマッチした。
/etc/rc.d/nfsd(起動スクリプト)を眺めてみると、依存するmountd(8),rpcbind(8)を起動してくれている。
ただrc.conf(5)に関係するものをすべて書いておいたほうがどのサービスが動いているのかがわかりやすいのでこうしている。
exports(5)を書き換えて設定を反映させたいときはmountd(8)を再起動しなければいけないので、
service(8)での明示的な起動と停止ができるこちらのほうが便利である。

::

  % vi /etc/exports
  V4: / -network 192.168.0.1 -mask 255.255.255.0
  /mnt/nfs -network 192.168.0.1 -mask 255.255.255.0

::

  % showmount -e
  Exports list on localhost:
  /mnt/nfs                   192.168.0.1
