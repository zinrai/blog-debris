nullfsを使いjailのportsを共有する
===========================================================================



.. author:: default
.. categories:: freebsd, jail
.. tags:: freebsd, nullfs, zfs, ports
.. comments::


jailを複数動かしているとports(Ports Collection)をどのように取り扱うかという壁にブチ当たると思う。
jailごとにportsnap fetchしているとportsnapサーバに負荷がかかるし、管理が面倒くさい。
ということでjailのportsは共有し、ホストからしかfetch,updateなどが出来ないようにしてみた。

:doc:`前回 <../22/freebsd_jail_vimage_zfs>` からの続きということで。

::

  # cd 9.1.0/sys/amd64/conf
  # cp VIMAGE NULLFS

  # vi VIMAGE
  options         NULLFS

  # cd /usr/src/9.1.0
  # make buildkernel KERNCONF=NULLFS
  # make installkernel KERNCONF=NULLFS
  # reboot

::

  # zfs create jails/ports
  # portsnap -p /jails/ports fetch
  # portsnap -p /jails/ports extract
  # portsnap -p /jails/ports update



設定があちこちに散らばると管理が面倒なのでnullfsのマウントはホストのfstabではなくjail.conf(5)に書く。

::

  # vi /etc/jail.conf

  exec.prestart  = "ifconfig epair${if} create up > /dev/null";
  exec.prestart += "ifconfig vswitch0 addm epair${if}a";
  exec.prestart += "mount -t nullfs -o ro /jails/ports /jails/${name}/usr/ports";
  exec.start     = "ifconfig lo0 up 127.0.0.1";
  exec.start    += "ifconfig epair${if}b up $ipaddr";
  exec.start    += "route add default 192.168.0.254";
  exec.start    += "sh /etc/rc";
  exec.stop      = "sh /etc/rc.shutdown";
  exec.poststop  = "ifconfig epair${if}a destroy";
  exec.poststop += "umount /jails/${name}/usr/ports";
  host.hostname = "${name}.localnet";
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

portsをリードオンリーでマウントしているのでビルド時の作業用ディレクトリが作成できない。
そのためjail環境のmake.conf(5)に作業ディレクトリの指定、ディレクトリを作成する必要がある。
設定した環境変数の説明はports(5)に書いてある。

::

  # vi /jails/test01/etc/make.conf

  WRKDIRPREFIX = /var/ports/
  DISTDIR = /var/ports/distfiles/
  PACKAGES = /var/ports/packages/

  # mkdir -p /jails/test01/var/ports/distfiles
  # mkdir -p /jails/test01/var/ports/packages

