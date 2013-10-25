Gentoo Linux rsync ロカールミラー
==============================================================



.. author:: default
.. categories:: gentoo
.. tags:: gentoo
.. comments::


Gentoo Linuxマシンを複数台動かしている場合、
それぞれのGentooマシンからemerge --syncするとリモートのミラーサーバに
負荷が掛かるのでローカルにミラーサーバを構築し参照するようにした。

サーバ
--------------------------------------------------------------

::

  % vi /etc/crontab
  0 23 * * * root emerge-webrsync

::

  % vi /etc/rsyncd.conf
  # /etc/rsyncd.conf

  # Minimal configuration file for rsync daemon
  # See rsync(1) and rsyncd.conf(5) man pages for help

  # This line is required by the /etc/init.d/rsyncd script
  pid file = /var/run/rsyncd.pid
  use chroot = yes
  read only = yes
  hosts allow = 192.168.2.0/24

  # Simple example for enabling your own local rsync server
  [gentoo-portage]
          path = /usr/portage
          comment = Gentoo Portage tree
          exclude = /distfiles /packages

::

 % /etc/init.d/rsyncd start
 % rc-update add rsyncd default


クライアント
--------------------------------------------------------------

::

  % rsync 192.168.2.1::
  gentoo-portage  Gentoo Portage tree

  % rsync 192.168.2.1::gentoo-portage | head
  drwxr-xr-x        4096 2013/10/25 10:30:12 .
  -rw-r--r--         121 2013/01/01 09:31:01 header.txt
  -rw-r--r--        3658 2013/01/01 09:31:01 skel.ChangeLog
  -rw-r--r--        8147 2013/01/01 09:31:01 skel.ebuild
  -rw-r--r--        1232 2013/03/06 06:31:01 skel.metadata.xml
  drwxr-xr-x        4096 2013/10/17 09:31:02 app-accessibility
  drwxr-xr-x       12288 2013/10/17 09:31:02 app-admin
  drwxr-xr-x        4096 2013/10/17 09:31:02 app-antivirus
  drwxr-xr-x        4096 2013/10/25 06:01:12 app-arch
  drwxr-xr-x        4096 2013/10/25 06:01:13 app-backup


::

  % vi /etc/portage/make.conf
  SYNC="rsync://192.168.2.1/gentoo-portage"

::

  % emerge --sync
