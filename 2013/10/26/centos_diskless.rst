CentOS ディスクレスブートサーバ構築
=============================================



.. author:: default
.. categories:: centos
.. tags:: centos
.. comments::

「 :doc:`../24/debian_wheezy_dnsmasq_proxy_dhcp` 」にCentOSのディスクレスブート環境を追加してみる。


::

  % cat /etc/centos-release
  CentOS release 6.4 (Final)

  % uname -a
  Linux localhost.localdomain 2.6.32-358.23.2.el6.x86_64 #1 SMP Wed Oct 16 18:37:12 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

::

  % yum groupinstall --releasever=6 --installroot=/var/diskless/centos6  Base -y
  % yum upgrade --releasever=6 --installroot=/var/diskless/centos6 -y


::

  % mount --rbind /dev /var/diskless/centos6/dev
  % cd /var/diskless/centos6
  % cp usr/share/zoneinfo/Asia/Tokyo etc/localtime
  % chroot /var/diskless/centos6 passwd
  % chroot /var/diskless/centos6 yum -y install kernel

  % vi /var/diskless/centos6/etc/fstab
  none    /tmp        tmpfs   defaults   0 0
  tmpfs   /dev/shm    tmpfs   defaults   0 0
  sysfs   /sys        sysfs   defaults   0 0
  proc    /proc       proc    defaults   0 0

  % vi /var/diskless/centos6/etc/resolv.conf
  nameserver 8.8.8.8

::

  % yum -y install dracut-network
  % dracut initramfs-`uname -r`.img


::

  % vi /etc/exports
  /var/diskless/centos6 192.168.2.0/24(rw,sync,no_root_squash,no_all_squash)

  % service rpcbind start
  % service nfslock start
  % service nfs start

あとはブートメニューにCentOSを追加するだけ。

::

  % vi /var/diskless/pxelinux.cfg/default
  default menu.c32
  label Debian wheezy
  kernel vmlinuz-3.2.0-4-amd64
  append initrd=initrd.img-3.2.0-4-amd64 root=/dev/nfs ip=dhcp nfsroot=192.168.2.100:/var/diskless/wheezy ro single

  label CentOS 6.4
  kernel vmlinuz-2.6.32-358.23.2.el6.x86_64
  append initrd=initramfs-2.6.32-358.23.2.el6.x86_64.img root=nfs:192.168.2.101:/var/diskless/centos6 rw


* http://www.server-world.info/query?os=CentOS_6&p=pxe&f=4
