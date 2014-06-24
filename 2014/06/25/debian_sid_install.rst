Debian sid インストール
====================================



.. author:: default
.. categories:: debian
.. tags:: debian, sid
.. comments::

wheezyからsidにdist-upgradeする。

wheezy
----------

::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2

  $ cat /etc/debian_version
  7.5

::

  $ diff -u sources.list.orig sources.list
  --- sources.list.orig   2014-06-23 21:52:33.706037290 +0900
  +++ sources.list        2014-06-23 21:53:03.154059993 +0900
  @@ -4,12 +4,12 @@

   # deb cdrom:[Debian GNU/Linux 7.5.0 _Wheezy_ - Official amd64 CD Binary-1 20140426-13:37]/ wheezy main

  -deb http://ftp.jp.debian.org/debian/ wheezy main
  -deb-src http://ftp.jp.debian.org/debian/ wheezy main
  +deb http://ftp.jp.debian.org/debian/ sid main
  +deb-src http://ftp.jp.debian.org/debian/ sid main

  -deb http://security.debian.org/ wheezy/updates main
  -deb-src http://security.debian.org/ wheezy/updates main
  +#deb http://security.debian.org/ wheezy/updates main
  +#deb-src http://security.debian.org/ wheezy/updates main

   # wheezy-updates, previously known as 'volatile'
  -deb http://ftp.jp.debian.org/debian/ wheezy-updates main
  -deb-src http://ftp.jp.debian.org/debian/ wheezy-updates main
  +#deb http://ftp.jp.debian.org/debian/ wheezy-updates main
  +#deb-src http://ftp.jp.debian.org/debian/ wheezy-updates main

::

  % apt-get update
  % apt-get upgrade
  % apt-get dist-upgrade
  % reboot

sid
----------

::

  $ uname -srv
  Linux 3.14-1-amd64 #1 SMP Debian 3.14.7-1 (2014-06-16)

  $ cat /etc/debian_version
  jessie/sid
