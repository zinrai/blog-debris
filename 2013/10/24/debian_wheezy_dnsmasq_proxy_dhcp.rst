Proxy DHCPを使ったディスクレスブート環境構築
================================================================



.. author:: default
.. categories:: dnsmasq
.. tags:: debian, wheezy, dnsmasq
.. comments::

Proxy DHCPを使ってDHCPサーバとネットワークブートサーバを切り離し、
ディスクレスブート環境を構築してみる。

DHCPサーバ,Proxy DHCPともにdnsmasq、OSはDebian wheezyを使用する。

::

  % lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.2 (wheezy)
  Release:        7.2
  Codename:       wheezy


DHCPサーバ
----------------------------------------------------------------

::

  % apt-get install dnsmasq

::

  % vi /etc/dnsmasq.d/dhcp.conf
  dhcp-range=192.168.2.230,192.168.2.253,2h
  dhcp-option=3,192.168.2.254

::

  % service dnsmasq restart


Proxy DHCP
----------------------------------------------------------------

::

  % apt-get install dnsmasq

::

  % vi /etc/dnsmasq.d/pxe.conf
  dhcp-range=192.168.2.0,proxy
  pxe-service=x86PC, "os install", pxelinux
  enable-tftp
  tftp-root=/var/diskless

Diskless Boot
----------------------------------------------------------------

::

  % apt-get install syslinux nfs-kernel-server debootstrap

::

  % debootstrap stable /var/diskless/wheezy http://ftp.jp.debian.org/debian
  % chroot /var/diskless/Wheezy passwd root

::

  % vi /etc/exports
  /var/diskless/wheezy 192.168.2.0/24(rw,no_root_squash,no_subtree_check)

::

  % mkdir /var/diskless
  % cp /usr/lib/syslinux/menu.c32 /var/diskless
  % cp /usr/lib/syslinux/pxelinux.0 /var/diskless
  % cp /boot/initrd* /var/diskless
  % cp /boot/vmlinuz* /var/diskless
  % mkdir /var/diskless/pxelinux.cfg

::

  % vi /var/diskless/pxelinux.cfg/default
  default menu.c32
  label Debian Wheezy
  kernel vmlinuz-3.2.0-4-amd64
  append initrd=initrd.img-3.2.0-4-amd64 root=/dev/nfs ip=dhcp nfsroot=192.168.2.100:/var/diskless/wheezy rw

::

  % service dnsmasq restart
  % service nfs-kernel-server restart
