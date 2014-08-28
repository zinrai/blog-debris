Debian sid で LXC を使ってみる
==========================================



.. author:: default
.. categories:: lxc
.. tags:: debian, sid, lxc, libvirt
.. comments::

::

  $ uname -srv
  Linux 3.14-2-amd64 #1 SMP Debian 3.14.15-2 (2014-08-09)

  $ cat /etc/debian_version
  jessie/sid

::

  $ apt-cache show lxc
  Package: lxc
  Version: 1:1.0.5-2
  Installed-Size: 2572
  Maintainer: Daniel Baumann <mail@daniel-baumann.ch>
  Architecture: amd64
  Replaces: lxc-dev
  Depends: init-system-helpers (>= 1.18~), libapparmor1 (>= 2.6~devel), libc6 (>= 2.17), libcap2 (>= 1:2.10), libseccomp2 (>= 2.1.0), libselinux1 (>= 1.32), python3 (<< 3.5), python3 (>= 3.4~)
  Pre-Depends: multiarch-support
  Recommends: lua5.2, rsync
  Suggests: debootstrap
  Conflicts: lxc-dev
  Description-en: Linux Containers userspace tools
   Containers are insulated areas inside a system, which have their own namespace
   for filesystem, network, PID, IPC, CPU and memory allocation and which can be
   created using the Control Group and Namespace features included in the Linux
   kernel.
   .
   This package provides the lxc-* tools, which can be used to start a single
   daemon in a container, or to boot an entire "containerized" system, and to
   manage and debug your containers.
  Description-md5: 4ece0dffd153c29e95ffdb89f8238dfc
  Homepage: http://linuxcontainers.org/
  Tag: admin::virtualization, implemented-in::c, interface::commandline,
   role::program, scope::application
  Section: admin
  Priority: optional
  Filename: pool/main/l/lxc/lxc_1.0.5-2_amd64.deb
  Size: 614156
  MD5sum: 641e858ffedc97f13bdeaf3631466870
  SHA1: 032bf1f0a88a4089d8f324411941b3f8b9d87f65
  SHA256: 51b6e745dc292f41b8cd66b55d9950794c1ee220b56aed483c5769e21795b0a7

::

  % apt-get install rsync bridge-utils libvirt-bin debootstrap dnsmasq lxc

ネットワーク設定
------------------------------

virsh net-startしようとするとebtablesがないと言われるのでインストールしておく。

::

  % apt-get install ebtables

::

  % vi /etc/libvirt/qemu/networks/default.xml
  <network>
    <name>default</name>
    <bridge name="virbr0"/>
    <forward/>
    <ip address="192.168.122.1" netmask="255.255.255.0">
      <dhcp>
        <range start="192.168.122.101" end="192.168.122.254"/>
      </dhcp>
    </ip>
  </network>

::

  % service dnsmasq stop
  % insserv -f -r dnsmasq

  % service libvirtd restart

  % virsh net-start default
  Network default started

  % virsh net-autostart default
  Network default marked as autostarted

LXC
------------------------------

::

  % vi /etc/fstab
  cgroup /sys/fs/cgroup cgroup defaults 0 0

  % mount -a

::

  % lxc-checkconfig
  Kernel configuration not found at /proc/config.gz; searching...
  Kernel configuration found at /boot/config-3.14-2-amd64
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

指定できるテンプレートが増えている。

::

  dpkg -L lxc | grep templates
  /usr/share/lxc/templates
  /usr/share/lxc/templates/lxc-centos
  /usr/share/lxc/templates/lxc-sshd
  /usr/share/lxc/templates/lxc-gentoo
  /usr/share/lxc/templates/lxc-fedora
  /usr/share/lxc/templates/lxc-debian
  /usr/share/lxc/templates/lxc-opensuse
  /usr/share/lxc/templates/lxc-ubuntu
  /usr/share/lxc/templates/lxc-alpine
  /usr/share/lxc/templates/lxc-download
  /usr/share/lxc/templates/lxc-cirros
  /usr/share/lxc/templates/lxc-oracle
  /usr/share/lxc/templates/lxc-openmandriva
  /usr/share/lxc/templates/lxc-ubuntu-cloud
  /usr/share/lxc/templates/lxc-archlinux
  /usr/share/lxc/templates/lxc-altlinux
  /usr/share/lxc/templates/lxc-busybox
  /usr/share/lxc/templates/lxc-plamo

::

  % lxc-create -n wheezy64 -t debian
  Root password is '4pb7+JAC', please change !

  % lxc-create -n jessie64 -t debian -- -r jessie
  Root password is '8o5yK1/4', please change !

  % lxc-create -n sid64 -t debian -- -r sid
  Root password is '+880EpXJ', please change !

rootパスワードがrootだったのがランダムな文字列を使うようになっていた。

::

  $ cat -n /usr/share/lxc/templates/lxc-debian
  154 password="$(dd if=/dev/urandom bs=6 count=1 2> /dev/null | base64)"
  155
  156 echo "root:$password" | chroot $rootfs chpasswd
  157 echo "Root password is '$password', please change !"

コンテナに必要なデバイスの設定をインクルードするようになっていた。
lxc.container.conf(5)に各パラメータについての説明がある。

::

  $ cat /var/lib/lxc/wheezy64/config
  # Template used to create this container: /usr/share/lxc/templates/lxc-debian
  # Parameters passed to the template:
  # For additional config options, please look at lxc.container.conf(5)
  lxc.network.type = empty
  lxc.rootfs = /var/lib/lxc/wheezy64/rootfs

  # Common configuration
  lxc.include = /usr/share/lxc/config/debian.common.conf

  # Container specific configuration
  lxc.mount = /var/lib/lxc/wheezy64/fstab
  lxc.utsname = wheezy64
  lxc.arch = amd64

::

  $ dpkg -L lxc | grep config
  /usr/bin/lxc-test-saveconfig
  /usr/bin/lxc-checkconfig
  /usr/bin/lxc-config
  /usr/share/man/man1/lxc-config.1.gz
  /usr/share/man/man1/lxc-checkconfig.1.gz
  /usr/share/man/ja/man1/lxc-config.1.gz
  /usr/share/man/ja/man1/lxc-checkconfig.1.gz
  /usr/share/lxc/config
  /usr/share/lxc/config/ubuntu.userns.conf
  /usr/share/lxc/config/debian.userns.conf
  /usr/share/lxc/config/gentoo.userns.conf
  /usr/share/lxc/config/fedora.common.conf
  /usr/share/lxc/config/ubuntu-cloud.lucid.conf
  /usr/share/lxc/config/ubuntu.lucid.conf
  /usr/share/lxc/config/centos.common.conf
  /usr/share/lxc/config/gentoo.moresecure.conf
  /usr/share/lxc/config/ubuntu-cloud.userns.conf
  /usr/share/lxc/config/oracle.userns.conf
  /usr/share/lxc/config/gentoo.common.conf
  /usr/share/lxc/config/fedora.userns.conf
  /usr/share/lxc/config/debian.common.conf
  /usr/share/lxc/config/centos.userns.conf
  /usr/share/lxc/config/plamo.common.conf
  /usr/share/lxc/config/ubuntu-cloud.common.conf
  /usr/share/lxc/config/oracle.common.conf
  /usr/share/lxc/config/ubuntu.common.conf
  /usr/share/lxc/config/common.seccomp
  /usr/share/lxc/config/plamo.userns.conf

ネットワーク設定もincludeするようにしてみた。

::

  % vi /root/network.dhcp.conf
  lxc.network.type = veth
  lxc.network.flags = up
  lxc.network.link = virbr0

::

  $ diff -u config.orig config
  --- config.orig 2014-08-28 22:01:31.180346690 +0000
  +++ config      2014-08-28 21:59:36.480344872 +0000
  @@ -11,3 +11,5 @@
   lxc.mount = /var/lib/lxc/wheezy64/fstab
   lxc.utsname = wheezy64
   lxc.arch = amd64
  +
  +lxc.include = /root/network.dhcp.conf

lxc-attach(1)が使えた。

::

  % lxc-start -n wheezy64 -d

  % lxc-attach -n wheezy64 -- cat /etc/debian_version
  7.6

  % lxc-attach -n wheezy64 -- apt-get update
  Hit http://cdn.debian.net wheezy Release.gpg
  Hit http://cdn.debian.net wheezy Release
  Hit http://cdn.debian.net wheezy/main amd64 Packages
  Get:1 http://cdn.debian.net wheezy/main Translation-en [3,847 kB]
  Fetched 3,847 kB in 3s (1,173 kB/s)
  Reading package lists... Done

  % lxc-attach -n wheezy64 -- apt-get upgrade
  Reading package lists... Done
  Building dependency tree... Done
  0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

lxc-list(1)はなくなっていた。lxc-ls(1)を使う。

::

  % lxc-ls -h
  usage: lxc-ls [-h] [-1] [-P PATH] [--active] [--frozen] [--running]
  [--stopped] [-f] [-F FANCY_FORMAT] [--nesting] [--version]
  [FILTER]

  LXC: List containers

  positional arguments:
  FILTER regexp to be applied on the container list

  optional arguments:
  -h, --help show this help message and exit
  -1 list one container per line (default when piped)
  -P PATH, --lxcpath PATH
  Use specified container path
  --active list only active containers
  --frozen list only frozen containers
  --running list only running containers
  --stopped list only stopped containers
  -f, --fancy use fancy output
  -F FANCY_FORMAT, --fancy-format FANCY_FORMAT
  comma separated list of fields to show
  --nesting show nested containers
  --version show program's version number and exit

  Valid fancy-format fields:
  name, state, ipv4, ipv6, autostart, pid, memory, ram, swap

  Default fancy-format fields:
  name, state, ipv4, ipv6, autostart

::

  % lxc-ls -f
  NAME      STATE    IPV4             IPV6  AUTOSTART
  ---------------------------------------------------
  jessie64  STOPPED  -                -     NO
  sid64     STOPPED  -                -     NO
  wheezy64  RUNNING  192.168.122.105  -     NO

bindmountはwheezyと同じ。

::

  % vi /var/lib/lxc/wheezy64/config
  lxc.mount.entry=/var/lib/jenkins /var/lib/lxc/wheezy64/rootfs/home none bind 0 0

/etc/lxc/auto,/usr/share/doc/lxc/README.Debianがなくなっており、Debian起動時にコンテナを起動させる方法がよくわからない。
