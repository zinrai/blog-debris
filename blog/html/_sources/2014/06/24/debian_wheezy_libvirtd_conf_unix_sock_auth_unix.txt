一般ユーザでvirt-managerを使う
===============================================================



.. author:: default
.. categories:: libvirt
.. tags:: debian, wheezy, libvirt
.. comments::


::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2

  $ cat /etc/debian_version
  7.5

Debianではユーザをlibvirtグループに追加するだけ。

::

  % gpasswd -a zinrai libvirt

これだけだと中身カラッポすぎるので、
なんでなのかをlibvirt本家ドキュメントとlibvirtのDebianディレクトリで調べてみた。

::

  $ wget http://ftp.de.debian.org/debian/pool/main/libv/libvirt/libvirt_0.9.12.3-1.debian.tar.gz
  $ tar zvxf libvirt_0.9.12.3-1.debian.tar.gz

::

  $ cat debian/patches/debian/Allow-libvirt-group-to-access-the-socket.patch
  From: Guido Guenther <agx@sigxcpu.org>
  Date: Thu, 26 Jun 2008 20:01:38 +0200
  Subject: Allow libvirt group to access the socket

  ---
   daemon/libvirtd.conf |    8 ++++----
   1 file changed, 4 insertions(+), 4 deletions(-)

  diff --git a/daemon/libvirtd.conf b/daemon/libvirtd.conf
  index 50eda1b..21cfcce 100644
  --- a/daemon/libvirtd.conf
  +++ b/daemon/libvirtd.conf
  @@ -78,7 +78,7 @@
   # without becoming root.
   #
   # This is restricted to 'root' by default.
  -#unix_sock_group = "libvirt"
  +unix_sock_group = "libvirt"

   # Set the UNIX socket permissions for the R/O socket. This is used
   # for monitoring VM status only
  @@ -95,7 +95,7 @@
   #
   # If not using PolicyKit and setting group ownership for access
   # control then you may want to relax this to:
  -#unix_sock_rw_perms = "0770"
  +unix_sock_rw_perms = "0770"

   # Set the name of the directory in which sockets will be found/created.
   #unix_sock_dir = "/var/run/libvirt"
  @@ -126,7 +126,7 @@
   #
   # To restrict monitoring of domains you may wish to enable
   # an authentication mechanism here
  -#auth_unix_ro = "none"
  +auth_unix_ro = "none"

   # Set an authentication scheme for UNIX read-write sockets
   # By default socket permissions only allow root. If PolicyKit
  @@ -135,7 +135,7 @@
   #
   # If the unix_sock_rw_perms are changed you may wish to enable
   # an authentication mechanism here
  -#auth_unix_rw = "none"
  +auth_unix_rw = "none"

   # Change the authentication scheme for TCP sockets.
   #

オリジナルソースではコメントアウトされているが、debパッケージ作成時にパッチが当たり、
libvirtグループに所属しているユーザはlibvirtのUNIX domain socketへの
読み書き実行権限が付与される設定になる。
auth_unix_{ro,rw}はパスワード認証やKerberos認証を使えたりするが、
デフォルトではこれらの認証方法は使わないようになっている。

* http://libvirt.org/auth.html
* http://libvirt.org/auth.html#ACL_server_unix_perms
* https://packages.debian.org/wheezy/libvirt-bin
