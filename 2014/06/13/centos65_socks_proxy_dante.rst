danteでSocks Proxy
====================================================



.. author:: default
.. categories:: dante
.. tags:: centos, socks, dante
.. comments::

会社で使う用事があったのでメモ。設定はここに載せているものとは違う。

::

  $ uname -a
  Linux proxy-server 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

::

  % rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

「enabled = 0」にして--enablerepoしなければrpmforgeを見に行かないようにしておく。

::

  % vi /etc/yum.repos.d/rpmforge.repo
  ### Name: RPMforge RPM Repository for RHEL 6 - dag
  ### URL: http://rpmforge.net/
  [rpmforge]
  name = RHEL $releasever - RPMforge.net - dag
  baseurl = http://apt.sw.be/redhat/el6/en/$basearch/rpmforge
  mirrorlist = http://mirrorlist.repoforge.org/el6/mirrors-rpmforge
  #mirrorlist = file:///etc/yum.repos.d/mirrors-rpmforge
  enabled = 0
  protect = 0
  gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
  gpgcheck = 1

Server
------------------------------

::

  $ yum --enablerepo=rpmforge info dante-server
  Installed Packages
  Name        : dante-server
  Arch        : x86_64
  Version     : 1.4.0
  Release     : 1.el6.rf
  Size        : 951 k
  Repo        : installed
  From repo   : rpmforge
  Summary     : free Socks v4/v5 server implementation
  URL         : http://www.inet.no/dante/
  License     : BSD-type
  Description : This package contains the socks proxy daemon and its
              : documentation. The sockd is the server part of the Dante socks
              : proxy package and allows socks clients to connect through it to
              : the network.

::

  % yum -enablerepo=rpmforge install dante-server

sockd.conf(5)を眺めて設定してみる。
sockd.conf(5)はサーバ設定、ルール、ルートの3つの構成になっている。
socks serverに関係するsocks-ruleとsocks clientに関係するclient-ruleの2つがあり、
socks-ruleなのかclient-ruleなのかを調べながら設定することになる。
ルール部では、ClientからServerへの接続可否、Serverからインターネット側への接続可否、
パケットをプロトコルごとに制限できたりする。
ルールは下記の表のようになっている。今回は動作する最低限の設定だけをした(client passとpassのみ)。

.. csv-table::

  client pass/block,clientからsocks serverへ接続可否ルール
  socks pass/block,socks serverから先の接続可否ルール
  pass, 許可するパケット
  block, 許可しないパケット

::

  $ diff -u /etc/sockd.conf.org /etc/sockd.conf
  --- /etc/sockd.conf.org 2014-06-13 17:08:02.910132544 +0000
  +++ /etc/sockd.conf     2014-06-13 17:47:31.482392599 +0000
  @@ -39,18 +39,19 @@
   #  Routes:

   # the server will log both via syslog, to stdout and to /var/log/sockd.log
  -#logoutput: syslog stdout /var/log/sockd.log
  -logoutput: stderr
  +logoutput: /var/log/sockd.log
  +#logoutput: stderr

   # The server will bind to the address 10.1.1.1, port 1080 and will only
   # accept connections going to that address.
   #internal: 10.1.1.1 port = 1080
   # Alternatively, the interface name can be used instead of the address.
  -#internal: eth0 port = 1080
  +internal: eth1 port = 1080

   # all outgoing connections from the server will use the IP address
   # 195.168.1.1
   #external: 192.168.1.1
  +external: eth1

   # list over acceptable methods, order of preference.
   # A method not set here will never be selected.
  @@ -61,9 +62,10 @@

   # methods for socks-rules.
   #method: username none #rfc931
  +socksmethod: none

   # methods for client-rules.
  -#clientmethod: none
  +clientmethod: none

   #or if you want to allow rfc931 (ident) too
   #method: username rfc931 none
  @@ -80,7 +82,7 @@
   #user.privileged: sockd

   # when running as usual, it will use the unprivileged userid of "sockd".
  -#user.unprivileged: sockd
  +user.unprivileged: nobody

   # If you compiled with libwrap support, what userid should it use
   # when executing your libwrap commands?  "libwrap".
  @@ -168,9 +170,14 @@
   # This is identical to above, but allows clients without a rfc931 (ident)
   # too.  In practice this means the socks server will try to get a rfc931
   # reply first (the above rule), if that fails, it tries this rule.
  -#client pass {
  -#        from: 10.0.0.0/8 port 1-65535 to: 0.0.0.0/0
  -#}
  +client pass {
  +        from: 10.8.8.0/24 port 1-65535 to: 0.0.0.0/0
  +        log: disconnect connect error
  +}
  +pass {
  +        from: 10.8.8.0/24 to: 0.0.0.0/0
  +        log: disconnect connect error
  +}


   # drop everyone else as soon as we can and log the connect, they are not

Client
------------------------------

::

  % yum -enablerepo=rpmforge install dante

環境変数を使う場合
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ export SOCKS_SERVER=192.168.0.1:1080
  $ export SOCKS_LOGOUTPUT=socks.log
  $ export SOCKS_DEBUG=1

設定ファイルに書く場合
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ diff -u /etc/socks.conf.org /etc/socks.conf
  --- /etc/socks.conf.org 2014-06-13 17:20:17.081206329 +0000
  +++ /etc/socks.conf     2014-06-13 17:21:03.865199065 +0000
  @@ -17,3 +17,7 @@
   #        proxyprotocol: socks_v4         # server supports socks v4.
   #        proxyprotocol: http             # server supports http.
   #}
  +route {
  +        from: 0.0.0.0/0   to: 0.0.0.0/0   via: 10.8.8.251 port = 1080
  +        proxyprotocol: socks_v5
  +}

socks.conf(5)を眺めてみると、resolveprotocolというパラメータ見付かる。
設定されていないければClientがUDPで名前解決を行う。
「resolveprotocol: fake」を設定するとSocks Serverに名前解決もしてもらうようになる。

あまり情報がないので本家ドキュメントやsockd.conf(5),socks.conf(5)を眺めてみることをお勧めする。

* http://www.inet.no/dante/index.html
* http://www.inet.no/dante/doc/latest/config/client.html
* http://www.inet.no/dante/doc/latest/config/server.html
