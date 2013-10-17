Supervisorを使ってuWSGIを管理
================================================



.. author:: default
.. categories:: supervisor
.. tags:: freebsd, supervisor, uwsgi
.. comments::


uWSGIのプロセスをSupervisorを使って管理してみる。

::

  % uname -a
  FreeBSD uwsgi.localnet 9.2-RELEASE FreeBSD 9.2-RELEASE #0 r256370: Sat Oct 12 22:47:21 JST 2013

  % python -V
  Python 2.7.5

  % supervisord -v
  3.0b1

  % uwsgi --version
  1.9.18.1


uWSGI
------------------------------

::

  % vi /path/app/dev.ini

  [uwsgi]
  http = :9090
  workers = 3
  virtualenv = /path/test
  python-path = /path/app
  wsgi = sample
  callable = app
  uid = www
  gid = www
  pidfile = /path/app/uwsgi.pid
  logto = /path/app/uwsgi.log
  log-format = %(addr) - %(user) [%(ltime)] "%(method) %(uri) %(proto)" %(status) %(size)`` "%(referer)" "%(uagent)"



Supervisor
------------------------------

::

  % cd /usr/local/etc
  % grep -v "^;" supervisord.conf.sample > supervisord.conf

::

  % vi /usr/local/etc/supervisord.conf

  [unix_http_server]
  file=/var/run/supervisor/supervisor.sock   ; (the path to the socket file)

  [supervisord]
  logfile=/var/log/supervisord.log ; (main log file;default $CWD/supervisord.log)
  logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
  logfile_backups=10          ; (num of main logfile rotation backups;default 10)
  loglevel=info               ; (log level;default info; others: debug,warn,trace)
  pidfile=/var/run/supervisor/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
  nodaemon=false              ; (start in foreground if true;default false)
  minfds=1024                 ; (min. avail startup file descriptors;default 1024)
  minprocs=200                ; (min. avail process descriptors;default 200)

  [rpcinterface:supervisor]
  supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

  [supervisorctl]
  serverurl=unix:///var/run/supervisor/supervisor.sock ; use a unix:// URL  for a unix socket

  [include]
  files = /usr/local/etc/supervisord.d/*.ini


::

  % vi /usr/local/etc/supervisord.d/uwsgi.ini

  [program:uwsgi]
  command = /path/bin/uwsgi /path/app/dev.ini
  stopasgroup = true

子プロセスまでkillするにはstopasgroupオプションが必要

stopasgroupオプションを有効にしなければ、Supervisor経由でuWSGIを止められない。
(stopasgroupオプションなしでは、Supervisorのstopを実行したときにuWSGIの親プロセスしかkillされず、
子プロセスが残ったままになってしまう。)

::

  % vi /etc/rc.conf
  supervisord_enable="YES"
  supervisord_flags="-c /usr/local/etc/supervisord.conf"

::

  % service supervisord start

::

  % supervisorctl status
  uwsgi                            RUNNING    pid 58014, uptime 0:15:23

  % supervisorctl stop uwsgi
  % supervisorctl start uwsgi


* http://supervisord.org/configuration.html
* http://uwsgi-docs.readthedocs.org/en/latest/Options.html
