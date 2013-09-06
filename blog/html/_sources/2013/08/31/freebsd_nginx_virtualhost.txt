Nginxでバーチャルホスト
===========================================================================



.. author:: default
.. categories:: nginx
.. tags:: freebsd, nginx
.. comments::


「 :doc:`../29/freebsd_packages_nginx` 」で課題にしていたnginxでのバーチャルホストの設定を行う。

バーチャルホストには

* **IPベース** : 1台のサーバに対して複数のドメイン,IPアドレスで運用する。
* **名前ベース** : 1台のサーバに対して複数のドメインを1つのIPアドレスで共用する。

の2種類がある。

今回は「名前ベース」のバーチャルホストを設定する。

dnsmasq
--------------------

:doc:`前回構築したDNSサーバ <../30/freebsd_dns_dnsmasq>` に名前を登録する。

::

  # vi /etc/hosts
  192.168.0.5 srv.localnet
  192.168.0.5 packages.localnet

  # service dnsmasq restart

Nginx
--------------------

nginxのほうも「 :doc:`../30/freebsd_dns_dnsmasq` 」と同じようにDebian Aapache2風のディレクトリ構成をとる。
最低限の設定しか載せていないので、他のパラメータはドキュメントを眺めながら各自で設定して欲しい。

::

  # nginx -v
  nginx version: nginx/1.4.2


::

  # cd /usr/local/etc/nginx
  # mkdir sites-available sites-enabled

  # vi nginx.conf
  http {
    include /usr/local/etc/nginx/sites-enabled/*;
  }

  # vi sites-available/packages.localnet
  server {
      listen 80;
      server_name packages.localnet;

      autoindex on;

      location / {
          root   /var/packages;
          index  index.html;
      }
  }

  # vi sites-avaliable/srv.localnet
  server {
      listen       80;
      server_name  srv.localnet;

      location / {
          root   /usr/local/www/nginx;
          index  index.html index.htm;
      }
  }

  # cd sites-enabled
  # ln -s ../sites-available/packages.localnet
  # ln -s ../sites-available/srv.localnet

  # service nginx start

packages.localnetにアクセスするとpackagesが見え、srv.localnetにアクセスするとnginxのインデックスページが見えれば
名前ベースバーチャルホストの設定は完了である。

* `http://ja.wikipedia.org/wiki/バーチャルホスト <http://ja.wikipedia.org/wiki/バーチャルホスト>`_
* http://nginx.org/en/docs/http/ngx_http_core_module.html#server
