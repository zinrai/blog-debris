CentOS 6.5 に nginx をインストール
==============================================



.. author:: default
.. categories:: nginx
.. tags:: centos, nginx
.. comments::

::

  $ uname -a
  Linux proxy-client01 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

::

  % yum install http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
  % rpm --import http://nginx.org/keys/nginx_signing.key

::

  $ cat /etc/yum.repos.d/nginx.repo
  # nginx.repo

  [nginx]
  name=nginx repo
  baseurl=http://nginx.org/packages/centos/6/$basearch/
  gpgcheck=1
  enabled=0

::

  $ yum info --enablerepo=nginx nginx
  Available Packages
  Name        : nginx
  Arch        : x86_64
  Version     : 1.6.0
  Release     : 1.el6.ngx
  Size        : 335 k
  Repo        : nginx
  Summary     : High performance web server
  URL         : http://nginx.org/
  License     : 2-clause BSD-like license
  Description : nginx [engine x] is an HTTP and reverse proxy server, as well as
              : a mail proxy server.

::

  % yum install --enablerepo=nginx nginx

* http://nginx.org/en/linux_packages.html
