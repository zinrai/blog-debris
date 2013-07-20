CentOS6.4にCobblerサーバ構築
============================================================



.. author:: default
.. categories:: centos,cobbler
.. tags:: centos,cobbler
.. comments::


サーバ100台くらいにOSインストールする作業が発生するかもしれないので怠けるための作業をメモしておく。
まずはCobblerサーバを構築してOSインストールが出来るまで。


::

  # uname -a
  Linux localhost.localdomain 2.6.32-358.11.1.el6.x86_64 #1 SMP Wed Jun 12 03:34:52 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  # cat /etc/centos-release
  CentOS release 6.4 (Final)


SELinuxを無効にしないとCobblerが動作しない。

下記のファイルを編集して再起動

::

  # vi /etc/selinux/config
  SELINUX=disabled

  # chkconfig xinetd on
  # chkconfig httpd on
  # chkconfig cobblerd on
  # chkconfig dhcpd on
  # reboot


::

  # rpm -i http://mirror.symnds.com/distributions/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm
  # yum -y install cobbler pykickstart dhcp

  # cobbler --version
  Cobbler 2.2.3
    source: ?, ?
    build time: Mon Jun 18 01:04:49 2012

  # cobbler check
  The following are potential configuration items that you may want to fix:

  1 : The 'server' field in /etc/cobbler/settings must be set to something other than localhost, or kickstarting features will not work.  This should be a resolvable hostname or IP for the boot server as reachable by all machines that will use it.
  2 : For PXE to be functional, the 'next_server' field in /etc/cobbler/settings must be set to something other than 127.0.0.1, and should match the IP of the boot server on the PXE network.
  3 : some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
  4 : change 'disable' to 'no' in /etc/xinetd.d/rsync
  5 : since iptables may be running, ensure 69, 80/443, and 25151 are unblocked
  6 : debmirror package is not installed, it will be required to manage debian deployments and repositories
  7 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
  8 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

  Restart cobblerd and then run 'cobbler sync' to apply changes.

  # /etc/init.d/cobblerd start

  # vi /etc/xinetd.d/rsync
  disable = no

  # vi /etc/xinetd.d/tftp
  disable = no

  # vi /etc/cobbler/settings
  server: 192.168.0.1
  manage_dhcp: 1
  next_server: 192.168.0.254 <- Gateway

  # vi /etc/cobbler/dhcp.template
  subnet 192.168.0.0 netmask 255.255.255.0 {
       option routers             192.168.0.254;
       option domain-name-servers 8.8.8.8;
       option subnet-mask         255.255.255.0;
       range dynamic-bootp        192.168.0.200 192.168.0.250;
       filename                   "/pxelinux.0";
       default-lease-time         21600;
       max-lease-time             43200;
       next-server                $next_server;
  }

  # /etc/init.d/iptables stop
  # /etc/init.d/xinetd restart
  # /etc/init.d/cobblerd restart

  # cobbler get-loaders
  # cobbler sync

  # cobbler import --path=rsync://ftp.jaist.ac.jp/pub/Linux/CentOS/6.4/os/x86_64/ --name=CentOS6.4_x86_64
  # cobbler sync


Cobblerを使いインストールするとデフォルトのパスワードはcobblerとなっている。

変更する場合は

::

  # cobbler check
  The following are potential configuration items that you may want to fix:

  1 : debmirror package is not installed, it will be required to manage debian deployments and repositories
  2 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
  3 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

  Restart cobblerd and then run 'cobbler sync' to apply changes.


に書いてあるように


::

  # openssl passwd -1 -salt "cobbler" "password"
  $1$cobbler$UTIGTKoLfLdeMAPNxROQZ1


を実行して


::

  # vi /etc/cobbler/settings
  default_password_crypted: "$1$cobbler$UTIGTKoLfLdeMAPNxROQZ1"


設定ファイルを書き換えてCobblerを再起動


::

  # /etc/init.d/cobblerd restart


* http://www.asahi-net.or.jp/~aa4t-nngk/pxeinstall.html
* http://blog.glidenote.com/blog/2012/03/15/cobbler-install/
* http://www.ibm.com/developerworks/jp/linux/library/l-cobbler/
