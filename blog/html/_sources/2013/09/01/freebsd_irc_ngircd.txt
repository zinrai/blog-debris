ngircdでIRCサーバ
======================================================



.. author:: default
.. categories:: freebsd, irc, ngircd
.. tags:: freebsd, irc, ngircd
.. comments::

IT系のアルバイトをしていたときにNagios,Zabbixなどから
定期的にメールがバンバン飛んできて、未読が4万通くらいになってメーラーを立ち上げるのを諦めたことがある。
なんでもかんでもメールで飛ばすのは嫌いだ。
メール振り分けなどの作業を各々がやらなければいけないなんて時間のムダだし、
集約できる情報を各々にわざわざ管理させ余計な負担を強いているのがイケてないと私はいつも思っている。

このイライラをIRCは解決してくれる。
IRCはチャットとして使うよりも、情報を集約させるのに非常に便利である。
Nagiosのアラート,SSHのログイン情報などをIRCにポストするようにしている。
IRCを積極的に使っている会社に勤めたことがないので個人でひっそりとやっているだけだが、
IRCを眺めれば何が起っているかわかり、いい感じである。


「つかれた」とポストしたら返事をしてくれる(妹)BOTを仕込んで荒んだ心を癒すことも出来る。

今回はIRCサーバ( `ngircd <http://ngircd.barton.de/>`_ )の構築を行う。

::

  # ngircd -V
  ngIRCd 20.2-IPv6+IRCPLUS+SSL+SYSLOG+TCPWRAP+ZLIB-amd64/portbld/freebsd9.1
  Copyright (c)2001-2013 Alexander Barton (<alex@barton.de>) and Contributors.
  Homepage: <http://ngircd.barton.de/>

  This is free software; see the source for copying conditions. There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


::

  # cd /usr/local/etc
  # touch ngircd.conf
  # yes | ngircd -t | tee ngircd.conf
  # echo "SUPER SONIKO" | tee ngircd.motd
  # cp ngircd.conf ngircd.conf.org


::

  # mkdir ngircd_ssl
  # cd ngircd_ssl

  # openssl dhparam -out dhparams.pem 2048.
  # openssl req -newkey rsa:2048 -x509 -keyout server-key.pem -out server-cert.pem -days 3650
  writing new private key to 'server-key.pem'
  Enter PEM pass phrase:
  Verifying - Enter PEM pass phrase:
  -----
  You are about to be asked to enter information that will be incorporated
  into your certificate request.
  What you are about to enter is what is called a Distinguished Name or a DN.
  There are quite a few fields but you can leave some blank
  For some fields there will be a default value,
  If you enter '.', the field will be left blank.
  -----
  Country Name (2 letter code) [AU]:
  State or Province Name (full name) [Some-State]:
  Locality Name (eg, city) []:
  Organization Name (eg, company) [Internet Widgits Pty Ltd]:
  Organizational Unit Name (eg, section) []:
  Common Name (e.g. server FQDN or YOUR name) []:
  Email Address []:


::

  # diff -u ngircd.conf.org ngircd.conf
  --- ngircd.conf.org     2013-08-31 12:44:37.665880056 +0900
  +++ ngircd.conf 2013-08-31 12:45:03.457801026 +0900
  @@ -1,17 +1,17 @@
   [GLOBAL]
  -  Name =
  +  Name = irc.hoge.localnet
     AdminInfo1 =
     AdminInfo2 =
  -  AdminEMail =
  +  AdminEMail = hoge@mail.localnet
     Info = ngIRCd 20.2
     Listen = ::,0.0.0.0
     MotdFile = /usr/local/etc/ngircd.motd
     MotdPhrase =
  -  Password =
  +  Password = aiueo
     PidFile =
     Ports = 6667
  -  ServerGID = wheel
  -  ServerUID = root
  +  ServerGID = nobody
  +  ServerUID = nobody

   [LIMITS]
     ConnectRetry = 60
  @@ -28,10 +28,10 @@
     ChrootDir =
     CloakHost =
     CloakHostModeX =
  -  CloakHostSalt = salt_mogemoge
  +  CloakHostSalt = salt_fugafuga
     CloakUserToNick = no
     ConnectIPv4 = yes
  -  ConnectIPv6 = yes
  +  ConnectIPv6 = no
     DNS = yes
     MorePrivacy = no
     NoticeAuth = no
  @@ -45,9 +45,9 @@
     WebircPassword =

   [SSL]
  -  CertFile =
  -  DHFile =
  -  KeyFile =
  -  KeyFilePassword =
  -  Ports =
  +  CertFile = /usr/local/etc/ngircd_ssl/server-cert.pem
  +  DHFile = /usr/local//etc/ngircd_ssl/dhparams.pem
  +  KeyFile = /usr/local/etc/ngircd_ssl/server-key.pem
  +  KeyFilePassword = kakikukeko
  +  Ports = 6669


設定ファイルのチェックをするオプションがあるので、これを使い設定をチェックする。
下記のように表示されれば設定は問題ない。

::

  # ngircd -t
  ngIRCd 20.2-IPv6+IRCPLUS+SSL+SYSLOG+TCPWRAP+ZLIB-amd64/portbld/freebsd9.1
  Copyright (c)2001-2013 Alexander Barton (<alex@barton.de>) and Contributors.
  Homepage: <http://ngircd.barton.de/>

  This is free software; see the source for copying conditions. There is NO
  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  Reading configuration from "/usr/local/etc/ngircd.conf" ...
  OK, press enter to see a dump of your server configuration ...


::

  # vi /etc/rc.conf
  ngircd_enable="YES"

  # service ngircd start


* http://ngircd.barton.de/documentation.php.en
