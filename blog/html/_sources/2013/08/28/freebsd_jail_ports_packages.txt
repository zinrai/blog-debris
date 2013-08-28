portsのパッケージをビルドする環境を構築する
=================================================================================



.. author:: default
.. categories:: freebsd, ports
.. tags:: freebsd, ports, packages, nullfs, zfs
.. comments::


FreeBSDを複数台動かす場合、パッケージをどのような手段でインストールするか考えることになると思う。

FreeBSDでのパッケージのインストールは

* **ports**: ソースコードをコンパイルしてインストール
* **packages**:  コンパイル済みのバイナリをインストール

の2種類が用意されている。

それぞれのFreeBSDにあるportsからパッケージをインストールするのは面倒だし、
コンパイルオプションの指定ミスなどが発生したとき原因調査に時間を取られて泣きをみることは間違いない。

というわけでpackagesを使いFreeBSDマシンにパッケージをインストールする。
packagesはFreeBSDから提供されているが、portsからも作成できる。
portsからだとコンパイルオプションを自分の好きなようにカスタマイズしたpackagesを作ることが出来る。
ただし、portsからpackagesを作成するにはパッケージをインストールしなければならない。

FreeBSDでは自前のpackagesを作成するツールとして「 `Tinderbox`_ 」が存在する。
「 `Tinderbox`_ 」は様々なユーザーランド,portsを組み合わせビルド環境を作り、packagesを作成してくれる。
WebUIも供えておりpackagesにしたいパッケージを登録すれば勝手にビルドしていく。
4.0.0からDBにSQLiteが使えるようになり導入のハードルがグッと下っているので気になったら触ってみて欲しい。

今回は「 `Tinderbox`_ 」は使わず、「 `Tinderbox`_ 」の動きを真似たビルド環境を自分で構築することにした。
下記の記事のような環境がすでに出来ているものとする。

* :doc:`../22/freebsd_jail_vimage_zfs`
* :doc:`../23/freebsd_jail_nullfs_ports`

::

  # zfs create jails/pkg
  # zfs create jails/buildbox

  # cd /usr/src/9.1.0
  # make buildworld
  # make installworld DESTDIR=/jails/buildbox
  # make distribution DESTDIR=/jails/buildbox


::

  # mkdir /jails/buildbox/usr/ports
  # mkdir /jails/buildbox/var/ports
  # cd /jails/pkg
  # mkdir distfiles packages coptions


::

  # vi /jails/buildbox//etc/resolv.conf
  nameserver 8.8.8.8


::

  # vi /jails/buildbox/etc/make.conf
  WRKDIRPREFIX = /var/ports/
  DISTDIR = /var/ports/distfiles/
  PACKAGES = /var/ports/packages/
  PORT_DBDIR = /var/ports/coptions/


::

  # vi /etc/jail.conf
  buildbox {
          exec.prestart += "mount -t nullfs /jails/pkg /jails/${name}/var/ports";
          exec.poststop += "umount /jails/${name}/var/ports";
          $if = 4;
          $ipaddr = 192.168.0.4;
  }


::

  # zfs snapshot jails/pkg@base
  # zfs snapshot jails/buildbox@base


::

  # jail -c buildbox


書いてある設定でピンときたでしょうが、ビルド作業用ディレクトリを別にマウントして
buildboxのほうはzfs rollbackでいつでも初期状態に戻せるようにしているだけである。

あとはjail環境で

::

  # cd /usr/ports/ftp/wget
  # make config-recursive
  # make install
  # make package-recursive

すれば/jails/pkg/packagesにpackagesが作られる。

packagesをどう配布するかは次の機会に。(調べればすぐに見付かるけど...)


* http://ftp.marcuscom.com/

.. _Tinderbox: http://ftp.marcuscom.com/
