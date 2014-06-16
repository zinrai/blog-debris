AIDEを使ってみた
==========================================



.. author:: default
.. categories:: aide
.. tags:: centos, aide
.. comments::

ファイルやディレクトリの整合性をチェックするAIDEを使ってみた。

::

  uname -a
  Linux proxy-client01 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  cat /etc/redhat-release
  CentOS release 6.5 (Final)

::

  $ yum info aide
  Available Packages
  Name        : aide
  Arch        : x86_64
  Version     : 0.14
  Release     : 3.el6_2.2
  Size        : 123 k
  Repo        : base
  Summary     : Intrusion detection environment
  URL         : http://sourceforge.net/projects/aide
  License     : GPLv2+
  Description : AIDE (Advanced Intrusion Detection Environment) is a file
              : integrity checker and intrusion detection program.

::

  % yum install -y aide

使い方や設定はaide(1),aide.conf(5)を眺めてみるといい。

.. csv-table::

  aide.db.gz,過去のある時点のスナップショット
  aide.db.new.gz,--init、--updateした時点のスナップショット

aide.db.gzは、--init時に生成されるaide.db.new.gzをコピーする。
aide.conf(5)のreport_urlでログをファイルに書き出す設定がされている。
ログファイルは追記ではなく上書きされる。
cron(8)などを使うときにはログファイルの扱いに気を付けたほうがよさそう。

::

  % aide -v
  Aide 0.14

  Compiled with the following options:

  WITH_MMAP
  WITH_POSIX_ACL
  WITH_SELINUX
  WITH_PRELINK
  WITH_XATTR
  WITH_LSTAT64
  WITH_READDIR64
  WITH_ZLIB
  WITH_GCRYPT
  WITH_AUDIT
  CONFIG_FILE = "/etc/aide.conf"

  % aide --init
  $ cd /var/lib/aide/
  % cp aide.db.new.gz aide.db.gz

::

  % yum install mlocate

checkオプションはaide.db.gzとの差分をstdoutするだけ。

::

  % aide --check
  AIDE found differences between database and filesystem!!
  Start timestamp: 2014-06-15 08:28:41

  Summary:
    Total number of files:        19859
    Added files:                  32
    Removed files:                0
    Changed files:                28


  ---------------------------------------------------
  Added files:
  ---------------------------------------------------

  added: /etc/cron.daily/mlocate.cron
  added: /etc/updatedb.conf
  added: /usr/share/locale/hu/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/sr@latin/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/pl/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/bg/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/it/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/fr/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/nl/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/ja/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/es/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/pt_BR/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/sr/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/zh_CN/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/ca/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/sv/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/pt/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/de/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/da/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/ms/LC_MESSAGES/mlocate.mo
  added: /usr/share/locale/cs/LC_MESSAGES/mlocate.mo
  added: /usr/share/man/man1/locate.1.gz
  added: /usr/share/man/man8/updatedb.8.gz
  added: /usr/share/man/man5/mlocate.db.5.gz
  added: /usr/share/man/man5/updatedb.conf.5.gz
  added: /usr/share/doc/mlocate-0.22.2
  added: /usr/share/doc/mlocate-0.22.2/AUTHORS
  added: /usr/share/doc/mlocate-0.22.2/COPYING
  added: /usr/share/doc/mlocate-0.22.2/NEWS
  added: /usr/share/doc/mlocate-0.22.2/README
  added: /usr/bin/updatedb
  added: /usr/bin/locate

  ---------------------------------------------------
  Changed files:
  ---------------------------------------------------

  changed: /etc/gshadow-
  changed: /etc/group-
  changed: /etc/group
  changed: /etc/gshadow
  changed: /usr/share/locale/hu/LC_MESSAGES
  changed: /usr/share/locale/sr@latin/LC_MESSAGES
  changed: /usr/share/locale/pl/LC_MESSAGES
  changed: /usr/share/locale/bg/LC_MESSAGES
  changed: /usr/share/locale/it/LC_MESSAGES
  changed: /usr/share/locale/fr/LC_MESSAGES
  changed: /usr/share/locale/nl/LC_MESSAGES
  changed: /usr/share/locale/ja/LC_MESSAGES
  changed: /usr/share/locale/es/LC_MESSAGES
  changed: /usr/share/locale/pt_BR/LC_MESSAGES
  changed: /usr/share/locale/sr/LC_MESSAGES
  changed: /usr/share/locale/zh_CN/LC_MESSAGES
  changed: /usr/share/locale/ca/LC_MESSAGES
  changed: /usr/share/locale/sv/LC_MESSAGES
  changed: /usr/share/locale/pt/LC_MESSAGES
  changed: /usr/share/locale/de/LC_MESSAGES
  changed: /usr/share/locale/da/LC_MESSAGES
  changed: /usr/share/locale/ms/LC_MESSAGES
  changed: /usr/share/locale/cs/LC_MESSAGES
  changed: /usr/share/man/man1
  changed: /usr/share/man/man8
  changed: /usr/share/man/man5
  changed: /usr/share/doc
  changed: /usr/bin

  --------------------------------------------------
  Detailed information about changes:
  ---------------------------------------------------


  File: /etc/gshadow-
    Size     : 414                              , 425
    Mtime    : 2014-03-07 11:53:23              , 2014-03-07 11:54:59
    Ctime    : 2014-03-07 11:54:59              , 2014-06-15 08:28:32
    MD5      : cvx+ZXNhPL78HfMjAbnH9g==         , 7hfWtwz10Tdya557L4uVZA==
    RMD160   : u42DRpXf1noceXiFwThBoVrSKDs=     , xE16Is6e+0GZw1cIQ1F+FHEZTJU=
    SHA256   : NJPbsAoNwx3SUna9m2BcyPBdUbaeNrZK , +hEhuoo1WSgYv6i5VPRKMrTDtIQ/7/5R

  File: /etc/group-
    Size     : 507                              , 521
    Mtime    : 2014-03-07 11:53:23              , 2014-03-07 11:54:59
    Ctime    : 2014-03-07 11:54:59              , 2014-06-15 08:28:32
    MD5      : MB8H+hstzr+hQ06tfwzt6Q==         , yTc/3lZVr0mPv+1Ycp/wtA==
    RMD160   : 1zqmuSo3YJ0GGfxyXk0NbcPbtgM=     , RbVuRqJWClm7vQBZtHGULs1OhhU=
    SHA256   : MiK+60AuFGpcxHGosswMwtIHBO9UxRiu , ZlxOVsf/Pl/NGak3/0AgjRbI/ZNxp+d5

  File: /etc/group
    Size     : 521                              , 535
    Mtime    : 2014-03-07 11:54:59              , 2014-06-15 08:28:32
    Ctime    : 2014-03-07 11:54:59              , 2014-06-15 08:28:32
    Inode    : 394246                           , 393881
    MD5      : yTc/3lZVr0mPv+1Ycp/wtA==         , +1LvvAILb+nxLPcanGE5cQ==
    RMD160   : RbVuRqJWClm7vQBZtHGULs1OhhU=     , YbvTQiKi/vb/lHr+RzusZ5ygFuo=
    SHA256   : ZlxOVsf/Pl/NGak3/0AgjRbI/ZNxp+d5 , +Qg4WQ9k1FqzIsYKkDpkbxUgVK2Z8jF+

  File: /etc/gshadow
    Size     : 425                              , 437
    Mtime    : 2014-03-07 11:54:59              , 2014-06-15 08:28:32
    Ctime    : 2014-03-07 11:54:59              , 2014-06-15 08:28:32
    Inode    : 393784                           , 393879
    MD5      : 7hfWtwz10Tdya557L4uVZA==         , 1wlrkrrGfjwLPjDe8yQPBA==
    RMD160   : xE16Is6e+0GZw1cIQ1F+FHEZTJU=     , Gu97aK52mdun+fpgto6xqRVoiMk=
    SHA256   : +hEhuoo1WSgYv6i5VPRKMrTDtIQ/7/5R , kr8w3IB3iDb1NAP0wSUS6mXYILzVU30L

  Directory: /usr/share/locale/hu/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/sr@latin/LC_MESSAGES
    Mtime    : 2014-06-14 13:08:59              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:08:59              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/pl/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/bg/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/it/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/fr/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/nl/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/ja/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/es/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/pt_BR/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/sr/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/zh_CN/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/ca/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/sv/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/pt/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/de/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/da/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/ms/LC_MESSAGES
    Mtime    : 2014-06-14 13:08:59              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:08:59              , 2014-06-15 08:28:32

  Directory: /usr/share/locale/cs/LC_MESSAGES
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/man/man1
    Mtime    : 2014-06-15 08:24:53              , 2014-06-15 08:28:32
    Ctime    : 2014-06-15 08:24:53              , 2014-06-15 08:28:32

  Directory: /usr/share/man/man8
    Mtime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:25              , 2014-06-15 08:28:32

  Directory: /usr/share/man/man5
    Mtime    : 2014-06-15 08:24:53              , 2014-06-15 08:28:32
    Ctime    : 2014-06-15 08:24:53              , 2014-06-15 08:28:32

  Directory: /usr/share/doc
    Mtime    : 2014-06-15 08:24:53              , 2014-06-15 08:28:32
    Ctime    : 2014-06-15 08:24:53              , 2014-06-15 08:28:32
    Linkcount: 44                               , 45

  Directory: /usr/bin
    Mtime    : 2014-06-14 13:09:27              , 2014-06-15 08:28:32
    Ctime    : 2014-06-14 13:09:27              , 2014-06-15 08:28:32

updateオプションはaide.db.new.gzを生成する。

::

  % aide --update

* http://aide.sourceforge.net/
