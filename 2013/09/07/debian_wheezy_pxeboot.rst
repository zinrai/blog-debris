シェルスクリプトでDebian wheezyのインストール自動化
==========================================================================



.. author:: default
.. categories:: debian, pxeboot
.. tags:: debian, wheezy, pexboot, debootstrap, dnsmasq
.. comments::


みなさん、Debianのインストール作業はどうやっているだろうか。
私は、OSのインストール作業なんてお金を貰わない限り手動でやりたくないので自動化している。
OSの手動インストールをするだけでお金が発生するのであれば喜んでやらせていただく所存である。
RedHat系の「 `Kickstart`_ 」と同じような仕組みの「 `preseed`_ 」というものがDebianにも存在するが、
これを使わずに「pxeboot + debootstrap + シェルスクリプト」でインストールの自動化をしている。

pxeboot
---------------------

::

  # apt-get install debootstrap syslinux dnsmasq nfs-kernel-server


dnsmasq
#####################

DNSサーバ以外にもDHCP,TFTPサーバとしても使える便利なdnsmasq

::

  # vi /etc/dnsmasq.d/pxe.conf
  enable-tftp
  tftp-root=/var/lib/tftpboot
  dhcp-range=192.168.2.200,192.168.2.250,2h
  dhcp-option=3,192.168.2.254
  dhcp-boot=pxelinux.0


NFS
#####################

::

  # vi /etc/exports
  /var/lib/tftpboot/wheezy 192.168.2.0/24(rw,no_root_squash,no_subtree_check)



debootstrap
#####################

::

  # mkdir -p /var/lib/tftpboot/wheezy
  # debootstrap stable /var/lib/tftpboot/wheezy http://ftp.jp.debian.org/debian
  # chroot /var/lib/tftpboot/wheezy/ apt-get install linux-image-`uname -r` parted build-essential bzip2 grub2 debootstrap


syslinux
#####################

::

  # cp /boot/initrd* /var/lib/tftpboot
  # cp /boot/vmlinuz* /var/lib/tftpboot

  # cp /usr/lib/syslinux/pxelinux.0 /var/lib/tftpboot
  # mkdir /var/lib/tftpboot/pxelinux.cfg

  # vi /var/lib/tftpboot/pxelinux.cfg/default
  default Debian
  prompt 1
  timeout 10
  label Debian
  kernel vmlinuz-3.2.0-4-amd64
  append initrd=initrd.img-3.2.0-4-amd64 root=/dev/nfs ip=dhcp nfsroot=192.168.2.253:/var/lib/tftpboot/wheezy ro single


::

  # service dnsmasq start
  # service nfs-kernel-server start

Debianインストールスクリプト
----------------------------------------

仕組みは「 :doc:`../../07/20/freebsd_pxeboot` 」と同じである。

debootstrapで取得した最小構成のWheezyをコピーするスクリプトを書いただけ。

パッケージインストール時にダイアログが表示され入力待ちにならないよう
環境変数「DEBIAN_FRONTEND=noninteractive」を設定しておくのがポイントである。

この環境変数は解決方法はないかとdebconf(1)を眺めていたら

::

  Debconf is a configuration system for Debian packages. For a debconf overview and documentation for sysadmins, see debconf(7) (in the debconf-doc package).

書かれており、説明に従いdebconf-docをインストールし、debconf(7)を眺めたところ見付けた。

os_install.shはconfファイルが1つだとうまく動いてくれないのでダミーのconfファイルを1つ作っておく。

::

  # touch /var/scripts/dummy.conf

::

  # mkdir -p /var/scripts/wheezy
  # debootstrap stable /var/scripts/wheezy http://ftp.jp.debian.org/debian


::

  # vi /var/scripts/os_install.sh

.. literalinclude:: ../../07/20/os_install.sh
   :language: bash


::

  # vi /var/scripts/debian_install.conf

.. literalinclude:: debian_install.conf
   :language: bash


pxeboot時にインストールスクリプトが実行されるようrc.localに書いておく。

::

  # vi /var/lib/tftpboot/wheezy/etc/rc.local

  #!/bin/sh -e
  #
  # rc.local
  #
  # This script is executed at the end of each multiuser runlevel.
  # Make sure that the script will "exit 0" on success or any other
  # value on error.
  #
  # In order to enable or disable this script just change the execution
  # bits.
  #
  # By default this script does nothing.

  /var/scripts/os_install.sh

  exit 0

.. _preseed: http://www.debian.org/releases/stable/amd64/apb.html.ja
.. _Kickstart: http://fedoraproject.org/wiki/Anaconda/Kickstart

* http://fedoraproject.org/wiki/Anaconda/Kickstart
* http://www.debian.org/releases/stable/amd64/apb.html.ja
