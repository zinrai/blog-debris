ZNCでIRC Proxy
=============================================



.. author:: default
.. categories:: freebsd, irc, znc
.. tags:: freebsd, irc, znc
.. comments::


IRCクライアオンからIRCサーバに接続してない間の発言は見ることが出来無い。
IRC Proxyを置けば接続していない間の発言を記録し、
IRCクライアントからIRC Proxyに接続すれば記録された発言を見ることが出来る。
IRC Proxyでログを定期的にメールすると外出中は捗る。
IRC Proxyといえばネットでは「 `Tiarra`_ 」をよく見掛けるが、
SSL接続のために「 `stone`_ 」などを使わなければならず面倒くさい。
SSL接続できるIRC Proxyはないか探してみたところ「 `ZNC`_ 」を見付け使っている。

* :doc:`../01/freebsd_irc_ngircd`

::

  # pw useradd -n znc -s /bin/tcsh -m
  # su - znc


::

  $ znc --help
  [ ** ] USAGE: znc [options]
  [ ** ] Options are:
  [ ** ]  -h, --help         List available command line options (this page)
  [ ** ]  -v, --version      Output version information and exit
  [ ** ]  -f, --foreground   Don't fork into the background
  [ ** ]  -D, --debug        Output debugging information (Implies -f)
  [ ** ]  -n, --no-color     Don't use escape sequences in the output
  [ ** ]  -r, --allow-root   Don't complain if ZNC is run as root
  [ ** ]  -c, --makeconf     Interactively create a new config
  [ ** ]  -s, --makepass     Generates a password for use in config
  [ ** ]  -p, --makepem      Generates a pemfile for use with SSL
  [ ** ]  -d, --datadir      Set a different ZNC repository (default is ~/.znc)

::

  $ znc -v
  ZNC 1.0 - http://znc.in
  IPv6: yes, SSL: yes, DNS: threads


::

  $ znc -c
  [ ok ] Checking for list of available modules...
  [ ** ] Building new config
  [ ** ]
  [ ** ] First let's start with some global settings...
  [ ** ]
  [ ?? ] What port would you like ZNC to listen on? (1025 to 65535): 6668
  [ ?? ] Would you like ZNC to listen using SSL? (yes/no) [no]: yes
  [ ** ] Unable to locate pem file: [/home/znc/.znc/znc.pem]
  [ ?? ] Would you like to create a new pem file now? (yes/no) [yes]:
  [ ok ] Writing Pem file [/home/znc/.znc/znc.pem]...
  [ ?? ] Would you like ZNC to listen using ipv6? (yes/no) [yes]: no
  [ ?? ] Listen Host (Blank for all ips): 192.168.0.8
  [ ok ] Verifying the listener...
  [ ** ]
  [ ** ] -- Global Modules --
  [ ** ]
  [ ** ] +-----------+----------------------------------------------------------+
  [ ** ] | Name      | Description                                              |
  [ ** ] +-----------+----------------------------------------------------------+
  [ ** ] | partyline | Internal channels and queries for users connected to znc |
  [ ** ] | webadmin  | Web based administration module                          |
  [ ** ] +-----------+----------------------------------------------------------+
  [ ** ] And 10 other (uncommon) modules. You can enable those later.
  [ ** ]
  [ ?? ] Load global module <partyline>? (yes/no) [no]:
  [ ?? ] Load global module <webadmin>? (yes/no) [no]:
  [ ** ]
  [ ** ] Now we need to set up a user...
  [ ** ]
  [ ?? ] Username (AlphaNumeric): hoge
  [ ?? ] Enter Password:
  [ ?? ] Confirm Password:
  [ ?? ] Would you like this user to be an admin? (yes/no) [yes]:
  [ ?? ] Nick [hoge]:
  [ ?? ] Alt Nick [hoge_]:
  [ ?? ] Ident [hoge]:
  [ ?? ] Real Name [Got ZNC?]: fuga
  [ ?? ] Bind Host (optional):
  [ ?? ] Number of lines to buffer per channel [50]:
  [ ?? ] Would you like to clear channel buffers after replay? (yes/no) [yes]:
  [ ?? ] Default channel modes [+stn]:
  [ ** ]
  [ ** ] -- User Modules --
  [ ** ]
  [ ** ] +--------------+------------------------------------------------------------------------------------------+
  [ ** ] | Name         | Description                                                                              |
  [ ** ] +--------------+------------------------------------------------------------------------------------------+
  [ ** ] | chansaver    | Keep config up-to-date when user joins/parts                                             |
  [ ** ] | controlpanel | Dynamic configuration through IRC. Allows editing only yourself if you're not ZNC admin. |
  [ ** ] | perform      | Keeps a list of commands to be executed when ZNC connects to IRC.                        |
  [ ** ] +--------------+------------------------------------------------------------------------------------------+
  [ ** ] And 22 other (uncommon) modules. You can enable those later.
  [ ** ]
  [ ?? ] Load module <chansaver>? (yes/no) [no]:
  [ ?? ] Load module <controlpanel>? (yes/no) [no]:
  [ ?? ] Load module <perform>? (yes/no) [no]:
  [ ** ]
  [ ?? ] Would you like to set up a network? (yes/no) [no]: yes
  [ ?? ] Network (e.g. `freenode' or `efnet'): hogeirc
  [ ** ]
  [ ** ] -- Network Modules --
  [ ** ]
  [ ** ] +-------------+-------------------------------------------------------------------------------------------------+
  [ ** ] | Name        | Description                                                                                     |
  [ ** ] +-------------+-------------------------------------------------------------------------------------------------+
  [ ** ] | chansaver   | Keep config up-to-date when user joins/parts                                                    |
  [ ** ] | keepnick    | Keep trying for your primary nick                                                               |
  [ ** ] | kickrejoin  | Autorejoin on kick                                                                              |
  [ ** ] | nickserv    | Auths you with NickServ                                                                         |
  [ ** ] | perform     | Keeps a list of commands to be executed when ZNC connects to IRC.                               |
  [ ** ] | simple_away | This module will automatically set you away on IRC while you are disconnected from the bouncer. |
  [ ** ] +-------------+-------------------------------------------------------------------------------------------------+
  [ ** ] And 16 other (uncommon) modules. You can enable those later.
  [ ** ]
  [ ?? ] Load module <chansaver>? (yes/no) [no]:
  [ ?? ] Load module <keepnick>? (yes/no) [no]:
  [ ?? ] Load module <kickrejoin>? (yes/no) [no]:
  [ ?? ] Load module <nickserv>? (yes/no) [no]:
  [ ?? ] Load module <perform>? (yes/no) [no]:
  [ ?? ] Load module <simple_away>? (yes/no) [no]:
  [ ** ]
  [ ** ] -- IRC Servers --
  [ ** ] Only add servers from the same IRC network.
  [ ** ] If a server from the list can't be reached, another server will be used.
  [ ** ]
  [ ?? ] IRC server (host only): 192.168.0.7
  [ ?? ] [192.168.50.7] Port (1 to 65535) [6667]: 6669
  [ ?? ] [192.168.50.7] Password (probably empty): aiueo
  [ ?? ] Does this server use SSL? (yes/no) [no]: yes
  [ ** ]
  [ ?? ] Would you like to add another server for this IRC network? (yes/no) [no]:
  [ ** ]
  [ ** ] -- Channels --
  [ ** ]
  [ ?? ] Would you like to add a channel for ZNC to automatically join? (yes/no) [yes]:
  [ ?? ] Channel name: #fuga
  [ ?? ] Would you like to add another channel? (yes/no) [no]:
  [ ?? ] Would you like to set up another network? (yes/no) [no]:
  [ ** ]
  [ ?? ] Would you like to set up another user? (yes/no) [no]:
  [ ok ] Writing config [/home/znc/.znc/configs/znc.conf]...
  [ ** ]
  [ ** ] To connect to this ZNC you need to connect to it as your IRC server
  [ ** ] using the port that you supplied.  You have to supply your login info
  [ ** ] as the IRC server password like this: user/network:pass.
  [ ** ]
  [ ** ] Try something like this in your IRC client...
  [ ** ] /server <znc_server_ip> +6668 hoge:<pass>
  [ ** ] And this in your browser...
  [ ** ] https://<znc_server_ip>:6668/
  [ ** ]
  [ ?? ] Launch ZNC now? (yes/no) [yes]:
  [ ok ] Opening config [/home/znc/.znc/configs/znc.conf]...
  [ ok ] Binding to port [+6668] on host [192.168.0.8] using ipv4...
  [ ** ] Loading user [hoge]
  [ ** ] Loading network [hogeirc]
  [ ok ] Adding server [192.168.0.7 +6669 aiueo]...
  [ ok ] Forking into the background... [pid: 42611]


::

  $ vi .znc/configs/znc.conf
  // WARNING
  //
  // Do NOT edit this file while ZNC is running!
  // Use webadmin or *controlpanel instead.
  //
  // Buf if you feel risky, you might want to read help on /znc saveconfig and /znc rehash.
  // Also check http://en.znc.in/wiki/Configuration

  Version = 1.0
  <Listener l>
          Port = 6668
          IPv4 = true
          IPv6 = false
          SSL = true
          Host = 192.168.0.8
  </Listener>

  <User hoge>
          Pass       = sha256#...#...#
          Admin      = true
          Nick       = hoge
          AltNick    = hoge_
          Ident      = hoge
          RealName   = fuga
          Buffer     = 50
          AutoClearChanBuffer = true
          ChanModes  = +stn


          <Network hogeirc>

                  Server     = 192.168.0.7 +6669 aiueo

                  <Chan #atchan>
                  </Chan>
          </Network>
  </User>


::

  # vi /etc/rc.conf
  znc_enable="YES"
  znc_user="znc"
  znc_conf_dir="/home/znc/.znc"

  # service znc start


WeeChat
------------------------------

「 `WeeChat`_ 」で「 `ZNC`_ 」に接続するには

::

  /server add hoge irc.hoge.localnet/6668 -ssl -username=hoge -password=hogepassword
  /connect hoge
  /disconnect hoge


* http://www.weechat.org/
* http://wiki.znc.in/Weechat
* http://wiki.znc.in/Using_commands

.. _WeecChat: http://www.weechat.org/
.. _ZNC: http://wiki.znc.in/ZNC
.. _Tiarra: http://www.clovery.jp/tiarra/
.. _stone: http://sourceforge.jp/projects/stone/

