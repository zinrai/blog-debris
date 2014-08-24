Debian wheezyでLXCを使ってみる
==================================



.. author:: default
.. categories:: lxc
.. tags:: debian, wheezy, lxc, libvirt
.. comments::

https://wiki.debian.org/LXC とREADME.Debianを見ながらDebian wheezyでLXCを使ってみた。


::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.60-1+deb7u3

  $ cat /etc/debian_version
  7.6

::

  % apt-cache show lxc
  Package: lxc
  Version: 0.8.0~rc1-8+deb7u2
  Installed-Size: 712
  Maintainer: Daniel Baumann <daniel.baumann@progress-technologies.net>
  Architecture: amd64
  Depends: debconf (>= 0.5) | debconf-2.0, libc6 (>= 2.8), libcap2 (>= 2.10)
  Pre-Depends: multiarch-support
  Recommends: debootstrap | cdebootstrap, rsync, libcap2-bin
  Suggests: lxctl
  Conflicts: cgroup-bin
  Description-en: Linux Containers userspace tools
   Containers are insulated areas inside a system, which have their own namespace
   for filesystem, network, PID, IPC, CPU and memory allocation and which can be
   created using the Control Group and Namespace features included in the Linux
   kernel.
   .
   This package provides the lxc-* tools, which can be used to start a single
   daemon in a container, or to boot an entire "containerized" system, and to
   manage and debug your containers.
  Homepage: http://lxc.sourceforge.net/
  Description-md5: 4ece0dffd153c29e95ffdb89f8238dfc
  Tag: admin::virtualization, implemented-in::c, interface::commandline,
   role::program, scope::application
  Section: admin
  Priority: optional
  Filename: pool/main/l/lxc/lxc_0.8.0~rc1-8+deb7u2_amd64.deb
  Size: 169900
  MD5sum: 00e9b7b812d6b156f0ea298b88ed6673
  SHA1: 74ccf808df7d19242ebf1a91a7f32fb66f39a6fc
  SHA256: 06f2ba886c07b0e224429f7b03802612ee58852d7b5be7e8e4b28d74dcd40119

::

  % apt-get install rsync bridge-utils libvirt-bin debootstrap dnsmasq lxc


ネットワーク設定
----------------------------------------

libvirtを使いvirbr0インタフェースを作成、ここにコンテナを接続する。

::

  $ cat /etc/libvirt/qemu/networks/default.xml
  <network>
  <name>default</name>
  <bridge name="virbr0" />
  <forward/>
  <ip address="192.168.122.1" netmask="255.255.255.0">
  <dhcp>
  <range start="192.168.122.2" end="192.168.122.254" />
  </dhcp>
  </ip>
  </network>

  % service dnsmasq stop
  % insserv -f -r dnsmasq
  % virsh net-autostart default
  % virsh net-start default

LXC
----------------------------------------

`Debian Wiki <https://wiki.debian.org/LXC>`_ の「Prepare the host」に書いてあるfstab(5)の設定ではcgroupsファイルシステムはマウントされない。
/usr/share/doc/lxc/README.Debianを読んだほうがいい。

::

  % vi /etc/fstab
  cgroup /sys/fs/cgroup cgroup defaults 0 0

  % mount -a

::

  % lxc-checkconfig
  Kernel config /proc/config.gz not found, looking in other places...
  Found kernel config file /boot/config-3.2.0-4-amd64
  --- Namespaces ---
  Namespaces: enabled
  Utsname namespace: enabled
  Ipc namespace: enabled
  Pid namespace: enabled
  User namespace: enabled
  Network namespace: enabled
  Multiple /dev/pts instances: enabled

  --- Control groups ---
  Cgroup: enabled
  Cgroup clone_children flag: enabled
  Cgroup device: enabled
  Cgroup sched: enabled
  Cgroup cpu account: enabled
  Cgroup memory controller: enabled
  Cgroup cpuset: enabled

  --- Misc ---
  Veth pair device: enabled
  Macvlan: enabled
  Vlan: enabled
  File capabilities: enabled

  Note : Before booting a new kernel, you can check its configuration
  usage : CONFIG=/path/to/config /usr/bin/lxc-checkconfig

テンプレート(シェルスクリプト)に従ってコンテナは作成される。

::

  % dpkg -L lxc | grep template
  /usr/share/lxc/templates
  /usr/share/lxc/templates/lxc-ubuntu-cloud
  /usr/share/lxc/templates/lxc-debian
  /usr/share/lxc/templates/lxc-debconf.d
  /usr/share/lxc/templates/lxc-debconf.d/03-debconf
  /usr/share/lxc/templates/lxc-debconf.d/03-debconf.templates
  /usr/share/lxc/templates/lxc-debconf.d/01-preseed-file.templates
  /usr/share/lxc/templates/lxc-debconf.d/01-preseed-file
  /usr/share/lxc/templates/lxc-debconf.d/02-preseed-debconf
  /usr/share/lxc/templates/lxc-fedora
  /usr/share/lxc/templates/lxc-sshd
  /usr/share/lxc/templates/lxc-archlinux
  /usr/share/lxc/templates/lxc-opensuse
  /usr/share/lxc/templates/lxc-debconf
  /usr/share/lxc/templates/lxc-altlinux
  /usr/share/lxc/templates/lxc-progress
  /usr/share/lxc/templates/lxc-progress.d

::

  % cat -n /usr/share/lxc/templates/lxc-debian
  293 usage()
  294 {
  295 cat <<EOF
  296 $1 -h|--help -p|--path=<path> [-a|--arch] [-r|--release=<release>] [-c|--clean]
  297 release: the debian release (e.g. wheezy): defaults to current stable
  298 arch: the container architecture (e.g. amd64): defaults to host arch
  299 EOF
  300 return 0
  301 }

::

  % lxc-create -h
  usage: lxc-create -n <name> [-f configuration] [-t template] [-h] [fsopts] -- [template_options]
  fsopts: -B none
  fsopts: -B lvm [--lvname lvname] [--vgname vgname] [--fstype fstype] [--fssize fssize]
  fsopts: -B btrfs
  flag is not necessary, if possible btrfs support will be used

  creates a lxc system object.

  Options:
  name : name of the container
  configuration: lxc configuration
  template : lxc-template is an accessible template script

  The container backing store can be altered using '-B'. By default it
  is 'none', which is a simple directory tree under /var/lib/lxc/<name>/rootfs
  Otherwise, the following option values may be relevant:
  lvname : [for -lvm] name of lv in which to create lv,
  container-name by default
  vgname : [for -lvm] name of vg in which to create lv, 'lxc' by default
  fstype : name of filesystem to create, ext4 by default
  fssize : size of filesystem to create, 500M by default

  for template-specific help, specify a template, for instance:
  lxc-create -t debconf -h

テンプレート側で用意している-rオプションを使うと指定したコードネームのベースイメージを取得できる。

::

  % MIRROR=http://ftp.jp.debian.org/debian lxc-create -n wheezy64 -t debian
  % MIRROR=http://ftp.jp.debian.org/debian lxc-create -n jessie64 -t debian -- -r jessie
  % MIRROR=http://ftp.jp.debian.org/debian lxc-create -n sid64 -t debian -- -r sid

::

  % lxc-list
  RUNNING

  FROZEN

  STOPPED
  jessie64
  sid64
  wheezy64

コンテナを外部と通信させるには下記の設定を追加する。

::

  % vi /var/lib/lxc/wheezy64/config
  lxc.network.type = veth
  lxc.network.flags = up
  lxc.network.link = virbr0


lxc-console(1)から抜ける場合は「Ctrl + a q」

::

  % lxc-start -n wheezy64 -d
  % lxc-console -n wheezy64

Debian起動時にコンテナを起動させておきたければ、/etc/lxc/autoにシンボリックリンクを張る。/usr/share/doc/lxc/README.Debianの「4. Autostart」に書かれている。

::

  % ln -s /var/lib/lxc/wheezy64/config /etc/lxc/auto/wheezy64

bindmountもできる。ホストのJenkinsディレクトリをコンテナにマウントするには下記の設定を追加する。

::

  % vi /var/lib/lxc/wheezy64/config
  lxc.mount.entry=/var/lib/jenkins /var/lib/lxc/wheezy64/rootfs/home none bind 0 0

lxc-attach(1)を使ってホストからコンテナへコマンドを実行させようとしたが、
Kernel 3.8以降でないとlxc-attach(1)はうまく動作しないようだ。

* https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=708144

wheezy-backportsにKernel 3.14のソースが置いてあるがビルドするのが面倒くさい。
Debian sidでもLXCを試してみようと思う。

* https://packages.debian.org/ja/wheezy-backports/linux-source
