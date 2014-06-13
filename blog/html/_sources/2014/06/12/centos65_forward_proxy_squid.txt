squidでForward Proxy Server
========================================================



.. author:: default
.. categories:: squid
.. tags:: centos, squid
.. comments::

yum(8)で取得するrpmをキャッシュさせたくて、squidでForward Proxy Serverを構築してみた。

::

  % uname -a
  Linux proxy-server 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  % cat /etc/redhat-release
  CentOS release 6.5 (Final)

squid
------------------------------

::

  $ yum info squid
  Available Packages
  Name        : squid
  Arch        : x86_64
  Epoch       : 7
  Version     : 3.1.10
  Release     : 20.el6_5.3
  Size        : 1.7 M
  Repo        : updates
  Summary     : The Squid proxy caching server
  URL         : http://www.squid-cache.org
  License     : GPLv2 and (LGPLv2+ and Public Domain)
  Description : Squid is a high-performance proxy caching server for Web clients,
              : supporting FTP, gopher, and HTTP data objects. Unlike traditional
              : caching software, Squid handles all requests in a single,
              : non-blocking, I/O-driven process. Squid keeps meta data and especially
              : hot objects cached in RAM, caches DNS lookups, supports non-blocking
              : DNS lookups, and implements negative caching of failed requests.
              :
              : Squid consists of a main server program squid, a Domain Name System
              : lookup program (dnsserver), a program for retrieving FTP data
              : (ftpget), and some management and client tools.

::

  % yum install squid

yum(8)で取得するrpmをキャッシュさせたいのでキャッシュするファイルの最大サイズを大きめに設定する。

::

  % diff -u squid.conf.org squid.conf
  --- squid.conf.org      2014-06-12 13:55:43.444802617 +0000
  +++ squid.conf  2014-06-13 01:35:22.999614814 +0000
  @@ -65,7 +65,11 @@
   hierarchy_stoplist cgi-bin ?

   # Uncomment and adjust the following to add a disk cache directory.
  -#cache_dir ufs /var/spool/squid 100 16 256
  +cache_mem 1024 MB
  +cache_dir ufs /var/spool/squid 4192 16 256
  +
  +maximum_object_size 128 MB
  +maximum_object_size_in_memory 10 MB

   # Leave coredumps in the first cache dir
   coredump_dir /var/spool/squid

::

  $ service squid start

squidclient(1)を使って、どれくれいキャッシュがヒットしているか調べてみた。

::

  % squidclient -p 3128 mgr:client_list
  Cache Clients:
  Address: 192.168.0.2
  Currently established connections: 0
      ICP  Requests 0
      HTTP Requests 180
          TCP_HIT                  106  59%
          TCP_MISS                  70  39%
          TCP_REFRESH_UNMODIFI       4   2%

  Address: ::1
  Name:    localhost
  Currently established connections: 1
      ICP  Requests 0
      HTTP Requests 2
          TCP_MISS                   2 100%

  TOTALS
  ICP : 0 Queries, 0 Hits (  0%)
  HTTP: 182 Requests, 110 Hits ( 60%)


client
------------------------------

yum(8)をProxy経由させるためにyum.conf(5)に設定する。

::

  % vi /etc/yum.conf
  proxy=http://192.168.0.1:3128/

  % yum update

* http://www.squid-cache.org/Doc/config/
* http://www.squid-cache.org/Doc/config/cache_mem/
* http://www.squid-cache.org/Doc/config/cache_dir/
* http://www.squid-cache.org/Doc/config/maximum_object_size/
* http://www.squid-cache.org/Doc/config/maximum_object_size_in_memory/
