Debian wheezy MySQL 5.6 インストール
========================================================================



.. author:: default
.. categories:: mysql
.. tags:: debian, wheezy, mysql
.. comments::

MySQL5.6をapt-get(8)できるように設定する。

::

  $ uname -a
  Linux zinrai 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2 x86_64 GNU/Linux

  $ cat /etc/debian_version
  7.5

::

  % dpkg -i mysql-apt-config_0.1.5-1debian7_all.deb

  $ cat /etc/apt/sources.list.d/mysql.list
  ### THIS FILE IS AUTOMATICALLY CONFIGURED ###
  # You may comment out this entry, but any other modifications may be lost.
  deb http://repo.mysql.com/apt/ stable mysql-5.6

::

  % apt-get update
  % apt-get install mysql-community-server

  % service mysql start

::

  % mysql -u root -p

  mysql> show databases;
  +--------------------+
  | Database           |
  +--------------------+
  | information_schema |
  | mysql              |
  | performance_schema |
  | test               |
  +--------------------+
  4 rows in set (0.00 sec)

  mysql> use test;
  Database changed

  mysql> show tables;
  Empty set (0.00 sec)

* http://dev.mysql.com/downloads/repo/apt/
* http://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/
