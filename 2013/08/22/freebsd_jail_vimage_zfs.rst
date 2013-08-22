FreeBSD 9.1 VIMAGE + ZFS で Jail環境構築
=====================================================================



.. author:: default
.. categories:: freebsd, jail, zfs
.. tags:: freebsd, jail, zfs
.. comments::


VIMAGE + ZFSでいくらでも作ったり、壊したり、巻き戻したり出来る環境を構築してみる。
jail環境をビルドするためにソースを取ってくる。ソースはsubversionで管理されている。まずsubversionをインストールから。

::


  # portsnap fetch
  # portsnap extract
  # portsnap update

  # cd /usr/ports/devel/subversion
  # make install

VIMAGEが使えるようにカーネルを再構築する。

::


  # cd /usr/src
  # svn checkout svn://svn.freebsd.org/base/release/9.1.0
  # cd 9.1.0/sys/amd64/conf
  # cp GENERIC VIMAGE

  # vi VIMAGE
  options         VIMAGE

  # cd /usr/src/9.1.0
  # make buildkernel KERNCONF=VIMAGE
  # make installkernel KERNCONF=VIMAGE
  # reboot


::

  # cd /usr/src/9.1.0
  # make buildworld
  # make installworld DESTDIR=/jails/test01
  # make distribution DESTDIR=/jails/test01


::

  # zpool list
  NAME    SIZE  ALLOC   FREE    CAP  DEDUP  HEALTH  ALTROOT
  jails   356G   900M   355G     0%  1.00x  ONLINE  -

  # zfs create jails/test01
  # zfs snapshot jails/test01@base
  # zfs clone jails/test01@base jails/test02


::

  # vi /etc/rc.conf

  ifconfig_re0=" inet 192.168.0.253 netmask 255.255.255.0"
  defaultrouter="192.168.0.254"

  cloned_interfaces="bridge0"
  ifconfig_bridge0_name="vswitch0"
  ifconfig_vswitch0="addm re0"

netstatしたときなどに/dev/kmem,/dev/memがないよと言われるので、
/etc/default/devfs.rulesを参考に、devfs.rules(5)のルールを追加しておく。

::

  # vi /etc/devfs.rules

  [devfsrules_jail=5]
  add include $devfsrules_hide_all
  add include $devfsrules_unhide_basic
  add include $devfsrules_unhide_login
  add path zfs unhide
  add path mem unhide
  add path kmem unhide


jailの設定はrc.conf(5)ではなくjail.conf(5)に書く。
jail(8)を眺めながら設定ファイルを書いてみた。
変数が使えていい感じ。
ネームサーバーを設定するパラメータが見当らないので、ネームサーバーの設定はjail内のresolv.confに書くことにする。

::

  # vi /etc/jail.conf

  exec.prestart  = "ifconfig epair${if} create up > /dev/null";
  exec.prestart += "ifconfig vswitch0 addm epair${if}a";
  exec.start     = "ifconfig lo0 up 127.0.0.1";
  exec.start    += "ifconfig epair${if}b up $ipaddr";
  exec.start    += "route add default 192.168.0.254";
  exec.start    += "sh /etc/rc";
  exec.stop      = "sh /etc/rc.shutdown";
  exec.poststop  = "ifconfig epair${if}a destroy";
  host.hostname  = "${name}.localnet";
  mount.devfs;
  devfs_ruleset = 5;
  vnet;
  vnet.interface = "epair${if}b";
  path = "/jails/${name}";
  persist;

  test01 {
          $if = 1;
          $ipaddr = 192.168.0.1;
  }

  test02 {
          $if = 2;
          $ipaddr = 192.168.0.2;
  }


::

  # jail -c test01
  # jls
     JID  IP Address      Hostname                      Path
      11  -               test01.localnet               /jails/test01

  # jexec 11 tcsh
  # jail -r test01


FreeBSD起動時にjailを起動させたければrc.conf(5)下記のように書いておく。

::

  # vi /etc/rc.conf

  jail_enable="YES"
  jail_list="test01 test02"

ZFSのスナップショット、ロールバックで何度でもやり直せる。

::

  # zfs snapshot jails/test01@snap01
  # zfs rollback jails/test01@snap01
  # zfs set quota=10g jails/test01
  # zfs clone jails/test01@snap01 jails/test03


* http://www.freebsd.org/doc/ja/books/handbook/svn-mirrors.html
* http://www.freebsd.org/doc/ja/books/handbook/kernelconfig-building.html
