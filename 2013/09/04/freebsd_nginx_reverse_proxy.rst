Nginxでリバースプロキシ
======================================================



.. author:: default
.. categories:: freebsd, nginx
.. tags:: freebsd, nginx
.. comments::


「 :doc:`../03/freebsd_jail_jenkins` 」からの続きでlocalhostでListenしているJenkinsを
Nginxのリバースプロキシを使いlocalhost以外からもアクセスできるようにする。

Nginxのディレクトリ構成は下記を参考に

* :doc:`../../08/31/freebsd_nginx_virtualhost`

::

  # nginx -v
  nginx version: nginx/1.4.2

::

  # vi /usr/local/etc/nginx/nginx.conf
  http {

      server {
          listen       80;
          server_name  localhost;

          location /jenkins {
              proxy_pass http://127.0.0.1:8180;
          }
  }

proxy_passを設定するだけでJenkinsに接続できるようになる。

「Python+ `Flask`_ + `uWSGI`_ 」で作ったAPサーバをバックエンドに置き、
リバースプロキシにNginxを使った場合を考えると、
上記の設定ではAPサーバのアクセスログにはリバースプロキシのIPアドレスが記録されてしまい
アクセス元はどこなのかがわからない状態になってしまう。
アクセス元のIPアドレスがAPサーバに記録されるようにするにはproxy_set_headerを設定する必要がある。

::

  # vi /usr/local/etc/nginx/nginx.conf
  http {

      server {
          listen       80;
          server_name  localhost;

          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Server $host;
          proxy_set_header X-Real-IP $remote_addr;

          location /myapp {
              proxy_pass http://127.0.0.1:9090;
          }
  }


.. _uWSGI: http://projects.unbit.it/uwsgi/
.. _Flask: http://flask.pocoo.org/

* http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass
* http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_set_header
