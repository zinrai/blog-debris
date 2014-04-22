FreeBSD 9.2 jail構築
==============================================



.. author:: default
.. categories:: freebsd
.. tags:: freebsd, jail, vimage
.. comments::

ezjail,qjailなどjailを管理するツールはあるけれどrc.conf(5)にjailの設定を書いて管理する方法を考えてみた。

rc.conf(5)はsh(1)によって読み込まれているので、指定したディレクトリに個々のjailの設定を置いてrc.conf(5)に
sourceすればいい感じではないかと思ったのでやってみた。
jail.conf(5)あるけどついカッとなってやってみた。後悔はしていない。

* :doc:`../../../2013/08/22/freebsd_jail_vimage_zfs`
* :doc:`../../../2013/08/23/freebsd_jail_nullfs_ports`

が出来上がっている前提で話を進めていく。

::

  $ uname -a
  FreeBSD hoge.localnet 9.2-RELEASE FreeBSD 9.2-RELEASE #0 r256370: Sat Oct 12 22:47:21 JST 2013     root@hoge.localnet:/usr/obj/usr/src/9.2.0/sys/VIMAGE  amd64

::

  % mkdir /usr/local/etc/rc.jail

::

  % vi /etc/rc.conf
  jail_enable="YES"

  for JAIL in /usr/local/etc/rc.jail/*.conf; do
    . $JAIL
  done

::

  % vi /usr/local/etc/rc.jail/testjail.conf
  . /usr/local/etc/rc.jail/jail_install.sh

  NAME="testjail"
  IFACE="6"
  IPADDR="192.168.0.6"
  NETMASK="255.255.255.0"
  GATEWAY="192.168.0.254"

  JAILROOT="/jails/${NAME}"

  if [ ! -d ${JAILROOT} ]; then
    zfs create jails/${NAME}
    jail_install ${JAILROOT}
  fi

  export jail_${NAME}_devfs_enable="YES"
  export jail_${NAME}_devfs_ruleset="devfsrules_jail2"
  export jail_${NAME}_nama="${NAME}"
  export jail_${NAME}_hostname="${NAME}.localnet"
  export jail_${NAME}_rootdir="${JAILROOT}"
  export jail_${NAME}_parameters="vnet"

  export jail_${NAME}_exec_prestart0="ifconfig epair${IFACE} create up"
  export jail_${NAME}_exec_prestart1="ifconfig vswitch0 addm epair${IFACE}a"
  export jail_${NAME}_exec_prestart2="mount -t nullfs -o ro /jails/ports /jails/${NAME}/usr/ports"

  export jail_${NAME}_exec_poststart0="ifconfig epair${IFACE}b vnet ${NAME}"
  export jail_${NAME}_exec_poststart1="jexec ${NAME} ifconfig lo0 127.0.0.1 up"
  export jail_${NAME}_exec_poststart2="jexec ${NAME} ifconfig epair${IFACE}b ${IPADDR} netmask ${NETMASK} up"
  export jail_${NAME}_exec_poststart3="jexec ${NAME} route add default ${GATEWAY}"

  export jail_${NAME}_exec_start0="sh /etc/rc"

  export jail_${NAME}_exec_stop0="sh /etc/rc.shutdown"

  export jail_${NAME}_exec_poststop0="ifconfig vswitch0 deletem epair${IFACE}a"
  export jail_${NAME}_exec_poststop1="ifconfig epair${IFACE}a destroy"
  export jail_${NAME}_exec_poststop2="umount /jails/${NAME}/usr/ports"

::

  % vi /etc/devfs.rules
  [devfsrules_jail2=5]
  add include $devfsrules_jail

  add path mem unhide
  add path kmem unhide

::

  % vi /usr/local/etc/rc.jail/jail_install.sh
  jail_install() {
    local JAILROOT=$1

    for FILE in *.txz; do
      tar xfzp $FILE -C $JAILROOT
    done

    cp /etc/resolv.conf $JAILROOT/etc
    cp /etc/localtime $JAILROOT/etc
    mkdir $JAILROOT/usr/ports
  }

bsdinstall(8)にjailというサブコマンドが用意されていてkernelを含まない環境を指定したディレクトリに展開してくれるけど、
毎回ファイルをネットから取りに行くのと、インタラクティブなのがつらかったので、ファイルを取得するところだけ眺めてみた。

::

  $ cat `which bsdinstall`
  exec "/usr/libexec/bsdinstall/$VERB" "$@" 2>> "$BSDINSTALL_LOG"

::

  $ cd /usr/libexec/bsdinstall
  $ file `ls` | grep -v "ELF"
  adduser:        POSIX shell script, ASCII text executable
  auto:           POSIX shell script, ASCII text executable
  checksum:       POSIX shell script, ASCII text executable
  config:         POSIX shell script, ASCII text executable
  docsinstall:    POSIX shell script, ASCII text executable
  hostname:       POSIX shell script, ASCII text executable
  jail:           POSIX shell script, ASCII text executable
  keymap:         POSIX shell script, ASCII text executable
  mirrorselect:   POSIX shell script, ASCII text executable, with very long lines
  mount:          POSIX shell script, ASCII text executable
  netconfig:      POSIX shell script, ASCII text executable
  netconfig_ipv4: POSIX shell script, ASCII text executable
  netconfig_ipv6: POSIX shell script, ASCII text executable
  rootpass:       POSIX shell script, ASCII text executable
  script:         POSIX shell script, ASCII text executable
  services:       POSIX shell script, ASCII text executable
  time:           POSIX shell script, ASCII text executable
  umount:         POSIX shell script, ASCII text executable
  wlanconfig:     POSIX shell script, ASCII text executable

::

  $ cat mirrorselect
  _UNAME_R=`uname -r`

  case ${_UNAME_R} in
          *-CURRENT|*-STABLE|*-PRERELEASE)
                  RELDIR="snapshots"
                  ;;
          *)
                  RELDIR="releases"
                  ;;
  esac

  BSDINSTALL_DISTSITE="$MIRROR/pub/FreeBSD/${RELDIR}/`uname -m`/`uname -p`/${_UNAME_R}"

mirrorselectで展開される `アドレス <ftp://ftp.jp.freebsd.org/pub/FreeBSD/releases/amd64/9.2-RELEASE/>`_ アクセスして
base.txzと必要なファイルをダウンロードする。

* http://qjail.sourceforge.net/
* http://erdgeist.org/arts/software/ezjail/
* http://www.freebsd.org/doc/ja/books/handbook/configtuning-core-configuration.html
* ftp://ftp.jp.freebsd.org/pub/FreeBSD/releases/amd64/9.2-RELEASE/
