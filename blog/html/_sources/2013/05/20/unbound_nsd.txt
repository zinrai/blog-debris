Unbound + NSD
======================



.. author:: default
.. categories:: nsd,unbound
.. tags:: unbound,nsd,dns,ubuntu
.. comments::



Chef Serverと戯れるときにhostsをいちいち書き換えるのは

面倒なので内部にDNSサーバを立ててみた。

.. csv-table:: Ubuntu 12.04 server amd64
  :delim: space
  :header-rows: 0

  コンテンツサーバ NSD(3.2.9) 192.168.0.1
  キャッシュサーバ Unbound(1.4.16) 192.168.0.2


NSD
--------------------

今回は正引きだけ設定した。

::

  # apt-get install nsd
  # cd /etc/nsd3
  # cp nsd.conf.sample nsd.conf
  # vi nsd.conf


::

  server:
    ip-address: 192.168.0.1
    hide-version: yes
    ipv4-only: yes
    database: "/etc/nsd3/nsd.conf"
    pidfile: "/etc/nsd3/nsd.pid"
    chroot: "/etc/nsd3"
    username: nsd
    zonedir: "/etc/nsd3"
    difffile: "/etc/nsd3/ixfr.db"
    xfrdfile: "/etc/nsd3/xfrd.state"

  zone:
    name: chef.local
    zonefile: chef.local.zone


::

  # vi chef.local.zone


::

  $TTL 3600
  @ IN SOA ns1.chef.local. postmaster.chef.local. (
    2013052001  ;Serial
    3600        ;Refresh
    1800        ;Retry
    57200       ;Expire
    86400       ;Minimum TTL
  )

  @ IN  NS  ns1.chef.local.

  ns1   IN  A 192.168.0.1
  ns2   IN  A 192.168.0.2
  www   IN  A 192.168.0.3
  hoge  IN  A 192.168.0.4
  fuga  IN  A 192.168.0.5
  moge  IN  A 192.168.0.6


Unbound
--------------------
::

  # apt-get install unbound
  # cd /etc/unbound
  # zcat `locate unbound.conf | sed -n 2p` > unbound.conf
  # vi unbound.conf


::

  server:
    verbosity: 1
    interface 192.168.0.2
    do-ip6: no
    access-control: 127.0.0.0/8 allow
    access-control: 192.168.0.0/24 allow
    chroot: "etc/unbound"
    username: "unbound"
    directory: "/etc/unbound"
    use-syslog: yes
    pidfile: "/etc/unbound/unbound.pid"

  stub-zone:
    name: "chef.local"
    stub-addr: 192.168.0.1

* http://unbound.jp/
* http://unbound.jp/news20110624/
* http://gihyo.jp/admin/feature/01/unbound
