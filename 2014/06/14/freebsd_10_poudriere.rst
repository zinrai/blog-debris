poudriereで自前のpkgリポジトリを作る
============================================================



.. author:: default
.. categories:: poudriere
.. tags:: freebsd, poudriere, packages, ports
.. comments::

以前ブログで書いたようなことをやってくれるツール(poudriere)があるということを知ったので使ってみた。

* :doc:`../../../2013/08/28/freebsd_jail_ports_packages`
* :doc:`../../../2013/08/29/freebsd_packages_nginx`

::

  % pkg update

  % pkg search -o poudriere
  ports-mgmt/poudriere
  ports-mgmt/poudriere-devel

  % pkg search -d poudriere
  poudriere-3.0.16:
  poudriere-devel-3.0.99.20140517_1:

  % pkg install poudriere

poudriere(8)にサブコマンドとオプションについての
説明がしっかり書かれているので、これを読めばハマることはあまりなさそう。
poudriere(8)はZFSを使うのでZFSのpoolを事前に作成しておく必要がある。

::

  % cd /usr/local/etc
  % cp poudriere.conf poudriere.conf.org

::

  $ diff -u poudriere.conf.org poudriere.conf
  --- poudriere.conf.org  2014-05-25 15:21:34.000000000 +0900
  +++ poudriere.conf      2014-05-25 15:27:09.000000000 +0900
  @@ -10,6 +10,7 @@
   # poudriere.
   #
   #ZPOOL=tank
  +ZPOOL=zpool_raidz

   ### NO ZFS
   # To not use ZFS, define NO_ZFS=yes
  @@ -26,7 +27,7 @@
   #
   # Also not that every protocols supported by fetch(1) are supported here, even
   # file:///
  -FREEBSD_HOST=_PROTO_://_CHANGE_THIS_
  +FREEBSD_HOST=ftp://ftp.jp.FreeBSD.org

   # By default the jails have no /etc/resolv.conf, you will need to set
   # REVOLV_CONF to a file on your hosts system that will be copied has
  @@ -136,6 +137,7 @@
   #
   # Cleanout the restricted packages
   # NO_RESTRICTED=yes
  +NO_RESTRICTED=yes

   # By default MAKE_JOBS is disabled to allow only one process per cpu
   # Use the following to allow it anyway

ports
------------------------------

poudriere(8)用のportsを展開する。

::

  % poudriere ports -c
  % poudriere ports -u

jail
------------------------------

poudriere(8)用のjailを作成する。

::

  % poudriere jail -c -j 10amd64 -v 10.0-RELEASE -a amd64
  % poudriere jail -d -j 10amd64

  % poudriere jail -l
  JAILNAME             VERSION              ARCH    METHOD
  10amd64              10.0-RELEASE         amd64   ftp

  % poudriere jail -u -j 10amd64

bulk
------------------------------

下記のようにテキストファイルにビルドしたいパッケージを記述して
読み込ませるだけで、あとは勝手にパッケージをビルドしてくれる。

::

  $ cat pkg_list.txt
  sysutils/tmux

::

  % poudriere bulk -f pkg_list.txt -j 10amd64
  % poudriere bulk -c -f pkg_list.txt -j 10amd64

options
------------------------------

bulkを実行する前にコンパイルオプションを指定したい場合はoptionsサブコマンドを使えばいい。

::

  % poudriere options -f pkg_list.txt -j 10amd64
  % poudriere options -n -f pkg_list.txt -j 10amd64
  % poudriere options -c -f pkg_list.txt -j 10amd64
  % poudriere options -C -f pkg_list.txt -j 10amd64
  % poudriere options -r -f pkg_list.txt -j 10amd64

packagesは下記のディレクトに配置される。
あとはWEBサーバを動かせば自前のpkgリポジトリの出来上がり。
便利すぎる...。

::

  % ls /usr/local/poudriere/data/packages/

https://fossil.etoilebsd.net/poudriere/doc/trunk/doc/index.wiki
