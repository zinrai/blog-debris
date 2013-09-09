CentOSでchroot環境構築
=======================================



.. author:: default
.. categories:: centos
.. tags:: centos, chroot
.. comments::


yum(8)では役割単位(Web,Mailサーバなど)でパッケージがグループ化されており、
グループ名を指定することでグループに属しているパッケージをまとめてインストールできるようになっている。

グループ名はサブコマンドgrouplistで調べることができる。

::

  # cat /etc/centos-release
  CentOS release 6.4 (Final)


::

  % yum grouplist
  Loaded plugins: fastestmirror
  Setting up Group Process
  Loading mirror speeds from cached hostfile
   * base: ftp.iij.ad.jp
   * extras: ftp.iij.ad.jp
   * updates: ftp.iij.ad.jp
  Installed Groups:
     E-mail server
  Available Groups:
     Additional Development
     Backup Client
     Backup Server
     Base
     CIFS file server
     Client management tools
     Compatibility libraries
     ~~~~~~~~~~以下略~~~~~~~~~~

サブコマンドgroupifnoでグループに属しているパッケージを調べられる。

::

  % yum groupinfo "E-mail Server"
  Loaded plugins: fastestmirror
  Setting up Group Process
  Loading mirror speeds from cached hostfile
   * base: ftp.iij.ad.jp
   * extras: ftp.iij.ad.jp
   * updates: ftp.iij.ad.jp

  Group: E-mail server
   Description: Allows the system to act as a SMTP and/or IMAP e-mail server.
   Default Packages:
     dovecot
     postfix
     spamassassin
   Optional Packages:
     cyrus-imapd
     dovecot-mysql
     dovecot-pgsql
     dovecot-pigeonhole
     mailman
     sendmail
     sendmail-cf


BaseはCentOSのベースシステムがグループ化されている。

さらに「--installroot」オプションで指定したディレクトリにベースシステムを展開できる。

これを使えばCentOSのchroot環境を簡単に構築できる。

::

  % yum -y --releasever=6 --installroot=/root/centos6 groupinstall "Base"
  % cd /root/centos6
  % cp usr/share/zoneinfo/Asia/Tokyo etc/localtime
  % cp /etc/resolv.conf etc/
  % chroot /root/centos6 ntpdate ntp.jst.mfeed.ad.jp
  % chroot /root/centos6 hwclock --systohc

  % mount --rbind /dev /root/centos6/dev
  % mount -t proc none /root/centos6/proc
  % mount --rbind /sys /root/centos6/sys

  % chroot /root/centos6 /bin/bash
