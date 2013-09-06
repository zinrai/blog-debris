dnsmasqを使ったDNSサーバ
=========================================================



.. author:: default
.. categories:: dnsmasq
.. tags:: freebsd, dnsmasq, dns
.. comments::


「 :doc:`../29/freebsd_packages_nginx` 」で課題にしていたDNSサーバ構築を行う。
DNSサーバというとBINDや `NSD`_ などが思い浮ぶだろうが、これらを使うのは腰が重い(とくにBIND、またはBIND、あるいはBIND)。

`dnsmasq`_ は少しの設定ファイル変更とhosts(5)を書くだけでDNSサーバとして機能する。
DHCP,TFTPサーバの機能も持っており、PXE Bootなどに使え非常に勝手がいい。


* :doc:`../22/freebsd_jail_vimage_zfs`
* :doc:`../23/freebsd_jail_nullfs_ports`
* :doc:`../28/freebsd_jail_ports_packages`
* :doc:`../29/freebsd_packages_nginx`


::

  # zfs clone jails/test01@base jails/dns


::

  # vi /etc/jail.conf
  dns {
          $if = 6;
          $ipaddr = 192.168.0.6;
  }


dns
--------------------

dnsmasqのpackagesはbuildboxで作成し、自前のpackages配布サーバを環境変数を設定しておく。

::

  # pkg_add -r dnsmasq
  # cd /usr/local/etc
  # cp dnsmasq.conf.example dnsmasq.conf

dnsmasq.confはdnsmasq.dディレクトリ下のファイルを読み込む設定だけ有効にしておく。
dnsmasq.confは600行くらいろいろ書いてあるので必要な設定項目だけをdnsmasq.dディレクトリ下に書いて管理したほうが設定を見通しやすい。
Debian Apache風にavailableディレクトリに設定ファイルを置き、有効にしたい設定だけをenableディレクトリにシンボリックリンクを貼る。
これで設定ファイルの切り替えが楽になる。

::

  # cd /usr/local/etc
  # mkdir -p dnsmasq.d/dnsmasq-available
  # mkdir -p dnsmasq.d/dnsmasq-enabled

  # vi dnsmasq.conf
  conf-dir=/usr/local/etc/dnsmasq.d/dnsmasq-enabled


::

  # vi dnsmasq.d/dnsmasq-avalilable/dns.conf

  # Never forward plain names (without a dot or domain part)
  domain-needed

  # Never forward addresses in the non-routed address spaces.
  bogus-priv

  # Add local-only domains here, queries in these domains are answered
  # from /etc/hosts or DHCP only.
  local=/localnet/

  # Set this (and domain: see below) if you want to have a domain
  # automatically added to simple names in a hosts-file.
  expand-hosts

  # Set the domain for dnsmasq. this is optional, but if it is set, it
  # does the following things.
  # 1) Allows DHCP hosts to have fully qualified domain names, as long
  #     as the domain part matches this setting.
  # 2) Sets the "domain" DHCP option thereby potentially setting the
  #    domain of all systems configured by DHCP
  # 3) Provides the domain part for "expand-hosts"
  domain=localnet


::

  # cd dnsmasq.d/dnsmasq-enabled
  # ln -s ../dnsmasq-available/dns.conf


::

  # vi /etc/hosts
  192.168.0.5 pkgsrv.localnet


::

  # vi /etc/rc.conf
  dnsmasq_enable="YES"

  # service dnsmasq start


これで自前のpackages配布サーバを名前で引けるようになった。
あとはresolv.confにdnsmasqが動いているサーバを指定するだけである。

* http://d.hatena.ne.jp/int128/20120226/1330247800


.. _NSD: http://www.nlnetlabs.nl/projects/nsd/
.. _dnsmasq: http://www.thekelleys.org.uk/dnsmasq/
