CentOS 6.5 で ClamAV を使ってみた
================================================================



.. author:: default
.. categories:: clamav
.. tags:: centos, clamav
.. comments::

::

  $ uname -srv
  Linux 2.6.32-431.20.3.el6.x86_64 #1 SMP Thu Jun 19 21:14:45 UTC 2014

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

::

  % yum install http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm

::

  $ cat /etc/yum.repos.d/epel.repo
  [epel]
  name=Extra Packages for Enterprise Linux 6 - $basearch
  #baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
  mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
  failovermethod=priority
  enabled=0
  gpgcheck=1
  gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

EPELだとclamavとclamdにパッケージが分かれている。
それぞれのパッケージに入っているものは表のようになっている。

.. csv-table::
  :widths: 7, 10, 30

  clamav , ,
  , clamscan, 単体で動作するウィルススキャン用コマンド
  , freshclam, ウィルス定義ファイルを更新するためのコマンド
  clamd , ,
  , clamd,ウィルススキャンデーモン
  , clamdscan, clamdクライアント

clamdとclamdscanはサーバ、クライアントモデルになっている。
clamdがウィルス定義ファイルをメモリに展開しデーモンとして常駐、clamdscanで問い合わせるという形になっている。
clamscanはスキャンのたびにウィルス定義ファイルを読み込むが、clamdはメモリに展開しているので高速に動作する。


clamav
-----------

::

  $ yum info --enablerepo=epel clamav
  Available Packages
  Name        : clamav
  Arch        : x86_64
  Version     : 0.98.3
  Release     : 1.el6
  Size        : 1.4 M
  Repo        : epel
  Summary     : Anti-virus software
  URL         : http://www.clamav.net/
  License     : GPLv2
  Description : Clam AntiVirus is a GPL anti-virus toolkit for UNIX. The main
              : purpose of this software is the integration with mail servers
              : (attachment scanning). The package provides a flexible and
              : scalable multi-threaded daemon, a command line scanner, and a
              : tool for automatic updating via Internet.
              :
              : The programs are based on a shared library distributed with the
              : Clam AntiVirus package, which you can use with your own software.
              : Most importantly, the virus database is kept up to date


::

  % yum --enablerepo=epel install clamav

::

  $ rpm -ql clamav
  /etc/freshclam.conf
  /usr/bin/clambc
  /usr/bin/clamscan
  /usr/bin/clamsubmit
  /usr/bin/freshclam
  /usr/bin/sigtool
  /usr/lib64/libclamav.so.6
  /usr/lib64/libclamav.so.6.1.22
  /usr/share/doc/clamav-0.98.3
  /usr/share/doc/clamav-0.98.3/AUTHORS
  /usr/share/doc/clamav-0.98.3/BUGS
  /usr/share/doc/clamav-0.98.3/COPYING
  /usr/share/doc/clamav-0.98.3/ChangeLog
  /usr/share/doc/clamav-0.98.3/FAQ
  /usr/share/doc/clamav-0.98.3/INSTALL
  /usr/share/doc/clamav-0.98.3/NEWS
  /usr/share/doc/clamav-0.98.3/README
  /usr/share/doc/clamav-0.98.3/clamav-mirror-howto.pdf
  /usr/share/doc/clamav-0.98.3/clamdoc.pdf
  /usr/share/doc/clamav-0.98.3/freshclam.conf
  /usr/share/doc/clamav-0.98.3/phishsigs_howto.pdf
  /usr/share/doc/clamav-0.98.3/signatures.pdf
  /usr/share/man/man1/clamscan.1.gz
  /usr/share/man/man1/clamsubmit.1.gz
  /usr/share/man/man1/freshclam.1.gz
  /usr/share/man/man1/sigtool.1.gz
  /usr/share/man/man5/freshclam.conf.5.gz

::

  $ clamscan -r /home/vagrant/
  /home/vagrant/.ssh/authorized_keys: OK
  /home/vagrant/.bash_logout: OK
  /home/vagrant/.bashrc: OK
  /home/vagrant/.bash_history: OK
  /home/vagrant/.lesshst: OK
  /home/vagrant/.vbox_version: OK
  /home/vagrant/.bash_profile: OK

  ----------- SCAN SUMMARY -----------
  Known viruses: 3473278
  Engine version: 0.98.3
  Scanned directories: 4
  Scanned files: 7
  Infected files: 0
  Data scanned: 0.00 MB
  Data read: 0.00 MB (ratio 0.00:1)
  Time: 5.791 sec (0 m 5 s)

他にもログをファイルに書き出したりするオプションもある。
clamscan(1)を眺めてみるといい。

clamd
-----------

::

  $ yum info --enablerepo=epel clamd
  Name        : clamd
  Arch        : x86_64
  Version     : 0.98.3
  Release     : 1.el6
  Size        : 159 k
  Repo        : epel
  Summary     : The Clam AntiVirus Daemon
  URL         : http://www.clamav.net/
  License     : GPLv2
  Description : The Clam AntiVirus Daemon

::

  % yum install --enablerepo=epel clamd

::

  $ rpm -ql clamd
  /etc/clamd.conf
  /etc/clamd.d
  /etc/logrotate.d/clamav
  /etc/rc.d/init.d/clamd
  /usr/bin/clamconf
  /usr/bin/clamdscan
  /usr/bin/clamdtop
  /usr/sbin/clamd
  /usr/share/clamav/README.clamd-wrapper
  /usr/share/clamav/clamd-wrapper
  /usr/share/doc/clamd-0.98.3
  /usr/share/doc/clamd-0.98.3/clamd.conf
  /usr/share/man/man1/clambc.1.gz
  /usr/share/man/man1/clamconf.1.gz
  /usr/share/man/man1/clamdscan.1.gz
  /usr/share/man/man1/clamdtop.1.gz
  /usr/share/man/man5/clamd.conf.5.gz
  /usr/share/man/man8/clamd.8.gz
  /var/lib/clamav
  /var/log/clamav
  /var/log/clamav/clamd.log
  /var/run/clamav

::

  % service clamd start

::

  % clamdscan /root
  clamdscan /root
  /root: lstat() failed: Permission denied. ERROR

インストール時の設定だと「Permission denied」となりスキャンできない。
そこで、clamd.confとclamd.conf(5)を眺めてみた。

::

       User STRING
              Run  the  daemon as a specified user (the process must be
              started by root).
              Default: disabled

::

  $ diff -u clamd.conf.orig clamd.conf
  --- clamd.conf.orig     2014-06-27 02:23:44.790917776 +0000
  +++ clamd.conf  2014-06-27 02:24:19.483912097 +0000
  @@ -192,7 +192,7 @@

   # Run as another user (clamd must be started by root for this option to work)
   # Default: don't drop privileges
  -User clam
  +#User clam

   # Initialize supplementary group access (clamd must be started by root).
   # Default: no

::

  % service clamd restart

デフォルトは「User clam」になっておりclamユーザで動作する。
「the process must be started by root」と書かれている通りrootユーザで動かすためにコメントアウトする。
これでclamdを再起動すればスキャンできるようになる。

freshclam
----------------------

proxyの設定もできたりする。freshclam.conf(5)

::

  $ diff -u freshclam.conf.org freshclam.conf
  --- freshclam.conf.org  2014-06-16 01:20:57.641926268 +0000
  +++ freshclam.conf      2014-06-16 01:21:43.073926648 +0000
  @@ -118,8 +118,8 @@

   # Proxy settings
   # Default: disabled
  -#HTTPProxyServer myproxy.com
  -#HTTPProxyPort 1234
  +HTTPProxyServer 192.168.0.1
  +HTTPProxyPort 3128
   #HTTPProxyUsername myusername
   #HTTPProxyPassword mypass

clamavインストール時に/etc/cron.dailyにfreshclamという名前のシェルスクリプトが
配置され、ウィルス定義ファイルの更新は毎日行われる。
あとはこのシェルスクリプトに「yum update --enablerepo=epel clamav clamd」でも仕込んでおけば
ClamAVあ本体のほうも最新に保てると思う。(EPELが小まめにClamAVを更新してくれていれば)

* http://www.clamav.net/lang/en/
* http://www.clamav.net/doc/latest/clamdoc.pdf
