uWSGIのログフォーマット
========================================================================



.. author:: default
.. categories:: uwsgi
.. tags:: freebsd, python, uwsgi
.. comments::


「 :doc:`../04/freebsd_nginx_reverse_proxy` 」でバックエンドに
アクセス元のIPアドレスがログに記録されると書いたが、
バックエンド側でも設定しなければログには記録されない。
個人でひっそりとWebサービスを運営していても
ディレクトリトラバーサルや某CMSを攻撃しているのかなと
思われるリクエストがログに記録されている。
ログを眺めるのは楽しいものだ。

今回はバックエンドに「 `uWSGI`_ 」を置いた場合のログ設定について書く。
動作するまでを書いた記事はよく見掛けるが、ログについて書いている記事は見たことがない。
ドキュメントに書いてある通りに設定すればいいだけなので、
わざわざ書き留めるほどの情報ではないのだろうか。

::

  # pw groupadd uwsgi -g 9090
  # pw useradd uwsgi -u 9090 -g 9090 -c "uWSGI" -d /nonexistent -s /usr/sbin/nologin


アクセスしたら「Hellow World」を出力するだけの `Flask`_ を使ったアプリケーション

::

  # vi sample.py
  from flask import Flask

  app = Flask(__name__)

  @app.route('/myapp')
  def hello_world():
      return "Hello World!"

  if __name__ == '__main__':
      app.run()

`uWSGI`_ の設定をいろいろと書いているが大事なのはlog-x-forwarded-forとlog-formatの部分である。
log-x-forwarded-forを有効にすればlog-formatの%(addr)にアクセス元のIPアドレスが記録される。

ログフォーマットは
「 `Formatting uWSGI requests logs <http://uwsgi-docs.readthedocs.org/en/latest/LogFormat.html>`_ 」
に詳しく書いてある。

::

  # vi development.ini
  [uwsgi]
  http = :9090
  workers = 3
  threads = 2
  virtualenv = ${virtualenv_path}
  python-path = ${application_path}
  wsgi = sample
  callable = app
  pidfile = /var/run/uwsgi.pid
  uid = uwsgi
  gid = uwsgi
  log-x-forwarded-for = true
  daemonize = uwsgi.log
  touch-reload = reload.txt
  log-format = %(addr) - %(user) [%(ltime)] "%(method) %(uri) %(proto)" %(status) %(size)`` "%(referer)" "%(uagent)"

.. csv-table::
  :widths: 30, 100

  virtualenv,virtualenvを使用している場合、virtualenvのパスを指定する
  python-path,アプリケーションのパスを指定する。
  touch-reload,指定したファイルをtouchすることでアプリと `uWSGI`_ の設定がリロードされる

::

  # touch reload.txt

::

  # uwsgi development.ini


.. _Flask: http://flask.pocoo.org/
.. _uWSGI: http://projects.unbit.it/uwsgi/

* http://uwsgi-docs.readthedocs.org/en/latest/WSGIquickstart.html
* http://uwsgi-docs.readthedocs.org/en/latest/Options.html
* http://uwsgi-docs.readthedocs.org/en/latest/LogFormat.html
