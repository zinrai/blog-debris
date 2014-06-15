CentOS 6.5 MySQL 5.6 インストール
================================================================



.. author:: default
.. categories:: mysql
.. tags:: centos, mysql
.. comments::

MySQL5.6をyum(8)できるようにした。

::

  $ uname -a
  Linux proxy-client02 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

インストール
--------------------

::

  % yum install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm

::

  $ yum info mysql-community-server
  Available Packages
  Name        : mysql-community-server
  Arch        : x86_64
  Version     : 5.6.19
  Release     : 2.el6
  Size        : 52 M
  Repo        : mysql56-community
  Summary     : A very fast and reliable SQL database server
  URL         : http://www.mysql.com/
  License     : Copyright (c) 2000, 2014, Oracle and/or its affiliates. All
              : rights reserved. Under GPLv2 license as shown in the Description
              : field.
  Description : The MySQL(TM) software delivers a very fast, multi-threaded,
              : multi-user, and robust SQL (Structured Query Language) database
              : server. MySQL Server is intended for mission-critical, heavy-load
              : production systems as well as for embedding into mass-deployed
              : software. MySQL is a trademark of Oracle and/or its affiliates
              :
              : The MySQL software has Dual Licensing, which means you can use
              : the MySQL software free of charge under the GNU General Public
              : License (http://www.gnu.org/licenses/). You can also purchase
              : commercial MySQL licenses from Oracle and/or its affiliates if
              : you do not wish to be bound by the terms of the GPL. See the
              : chapter "Licensing and Support" in the manual for further info.
              :
              : The MySQL web site (http://www.mysql.com/) provides the latest
              : news and information about the MySQL software.  Also please see
              : the documentation and the manual for more information.
              :
              : This package includes the MySQL server binary as well as related
              : utilities to run and administer a MySQL server.

::

  % yum install mysql-community-server

my.cnf
--------------------

::

  $ diff -u my.cnf.org my.cnf
  --- my.cnf.org  2014-06-14 16:26:43.920377328 +0000
  +++ my.cnf      2014-06-15 06:04:20.169191216 +0000
  @@ -26,6 +26,8 @@
   # Recommended in standard MySQL setup
   sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

  +character-set-server = utf8
  +
   [mysqld_safe]
   log-error=/var/log/mysqld.log
   pid-file=/var/run/mysqld/mysqld.pid

起動してcharacter_setやstatusを見てみる。

::

  $ mysql -u root -p

  mysql> show variables like 'char%';
  +--------------------------+----------------------------+
  | Variable_name            | Value                      |
  +--------------------------+----------------------------+
  | character_set_client     | utf8                       |
  | character_set_connection | utf8                       |
  | character_set_database   | utf8                       |
  | character_set_filesystem | binary                     |
  | character_set_results    | utf8                       |
  | character_set_server     | utf8                       |
  | character_set_system     | utf8                       |
  | character_sets_dir       | /usr/share/mysql/charsets/ |
  +--------------------------+----------------------------+
  8 rows in set (0.00 sec)

  mysql> status;
  --------------
  mysql  Ver 14.14 Distrib 5.6.19, for Linux (x86_64) using  EditLine wrapper

  Connection id:          3
  Current database:
  Current user:           root@localhost
  SSL:                    Not in use
  Current pager:          stdout
  Using outfile:          ''
  Using delimiter:        ;
  Server version:         5.6.19 MySQL Community Server (GPL)
  Protocol version:       10
  Connection:             Localhost via UNIX socket
  Server characterset:    utf8
  Db     characterset:    utf8
  Client characterset:    utf8
  Conn.  characterset:    utf8
  UNIX socket:            /var/lib/mysql/mysql.sock
  Uptime:                 1 hour 40 min 43 sec

  Threads: 1  Questions: 10  Slow queries: 0  Opens: 67  Flush tables: 1  Open tables: 60  Queries per second avg: 0.001
  --------------

* http://dev.mysql.com/downloads/repo/yum/
* http://dev.mysql.com/doc/refman/5.6/en/server-options.html
