jail環境でJenkinsを動かす
============================================================



.. author:: default
.. categories:: freebsd, jail, jenkins
.. tags:: freebsd, jail, jenkins
.. comments::


会社員だったときに仕様書がエルセル方眼紙だったので、
「 `Sphinx`_ にするとプレーンテキストで管理でき、gitなどのバージョン管理システムの管理下に置け、
さらに `Jenkins`_ を使えば手元に `Sphinx`_ がなくてもバージョン管理下に置いたソースを
リモートリポジトリにpushするだけでビルドしてくれる環境ができますよ」
というようなことをもう少しわかりやすく提案し見事に却下された。
エクセル方眼紙は3人で編集していたのでマージ作業が辛かった。

jail環境の構築は下記を参考に

* :doc:`../../08/22/freebsd_jail_vimage_zfs`

FreeBSDにJenkinsをインストールするとインストール後に下記のように表示される。

::

  ======================================================================

  This OpenJDK implementation requires fdescfs(5) mounted on /dev/fd and
  procfs(5) mounted on /proc.

  If you have not done it yet, please do the following:

          mount -t fdescfs fdesc /dev/fd
          mount -t procfs proc /proc

  To make it permanent, you need the following lines in /etc/fstab:

          fdesc   /dev/fd         fdescfs         rw      0       0
          proc    /proc           procfs          rw      0       0

  ======================================================================

jail環境ではマウントできないのでホストのjail.conf(5)にjail起動時にマウントするよう書いておく。

::

  # vi /etc/jail.conf
  jenkins {
          exec.prestart += "mount -t fdescfs fdesc /jails/${name}/dev/fd";
          exec.prestart += "mount -t procfs proc /jails/${name}/proc";
          exec.poststop += "umount /jails/${name}/dev/fd";
          exec.poststop += "umount /jails/${name}/proc";
          $if = 9;
          $ipaddr = 192.168.0.9;
  }


jenkins
------------------------------

::

  # vi /etc/rc.conf
  jenkins_enable="YES"

  # service jenkins start

JenkinsはlocalhostでListenしているので、このままだと他からアクセスできない。

次回はリバースプロキシにnginxを使いJenkinsにアクセスできるようにする。


.. _Sphinx: http://sphinx-doc.org/
.. _Jenkins: http://jenkins-ci.org/

* http://sphinx-users.jp/
* http://build-shokunin.org/
