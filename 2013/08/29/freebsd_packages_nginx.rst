packages配布サーバ構築
==================================================================



.. author:: default
.. categories:: freebsd, nginx
.. tags:: freebsd, nginx, packages
.. comments::


:doc:`前回 <../28/freebsd_jail_ports_packages>` はpackagesを作成する環境を構築した。

今回は作成したpackagesを各FreeBSDマシンに配布する環境を構築する。

* :doc:`../22/freebsd_jail_vimage_zfs`
* :doc:`../23/freebsd_jail_nullfs_ports`
* :doc:`../28/freebsd_jail_ports_packages`

jails/pkg/packagesにpackagesが作られているので配布サーバ用jailにリードオンリーでマウントして
Webサーバ(nginx)を動かすだけの簡単なお仕事である。

::

  # zfs clone jails/test01@base jails/pkgsrv
  # mkdir /jails/pkgsrv/var/packages


::

  # vi /etc/jail.conf
  test02 {
          $if = 2;
          $ipaddr = 192.168.0.2;
  }

  pkgsrv {
          exec.prestart += "mount -t nullfs -o ro /jails/pkg/packages /jails/${name}/var/packages";
          exec.poststop += "umount /jails/${name}/var/packages";
          $if = 5;
          $ipaddr = 192.168.0.5;
  }


pkgsrv
--------------------

pkgsrvにpackagesのnginxをインストールするためbuildboxでnginxをビルドしておく。

::

  # cd /var/packages/Latest
  # pkg_add nginx

  # cd /usr/local/nginx
  # cp nginx.conf nginx.conf.bak

  # mkdir /var/tmp/nginx
  # touch /var/tmp/nginx/client_body_temp

serverブロックに以下のように書いていればとりあえず目的は達成できる。

::

  # vi /usr/local/nginx/nginx.conf
  server {
          autoindex on;

          location / {
              root   /var/packages;
              index  index.html index.htm;
              allow 192.168.0.0/24;
              deny all;
          }
  }


::

  # nginx -t
  nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
  nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful

  # service nginx onestart


test02
--------------------

pkg_add(1)は環境変数を設定することで取得するpackagesのサーバを指定できる。
環境変数の設定方法は調べればいくらでも引っ掛かるのでcshでの設定のみ書いておく。

::

  # vi .cshrc
  setenv PACKAGEROOT http://192.168.0.5/
  setenv PACKAGESITE http://192.168.0.5/Latest/

  # source .cshrc
  # pkg_add -r wget


packages配布サーバの構築は無事に完了した。
ただ、IP直打ちだと配布サーバのIPを変更したとき環境変数を書き換えなければならず面倒だし、nginxを配布サーバ以外のことにも使いたい。

というわけで


* DNSサーバの構築
* nginx バーチャルホストの設定

を課題としておく。
