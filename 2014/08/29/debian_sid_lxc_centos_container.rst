Debian sid で CentOS の LXCテンプレートを試してみた
==============================================================



.. author:: default
.. categories:: lxc
.. tags:: debian, sid, lxc, centos
.. comments::


* :doc:`../../08/28/debian_sid_lxc`

::

  % uname -srv
  Linux 3.14-2-amd64 #1 SMP Debian 3.14.15-2 (2014-08-09)

  % cat /etc/debian_version
  jessie/sid

templateにCentOSがあったので試してみた。

::

  $ dpkg -L lxc | grep template
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

-Rでリリース番号、-aでarchを指定できる。

::

  $ cat -n /usr/share/lxc/templates/lxc-centos
  645 usage()
  646 {
  647 cat <<EOF
  648 usage:
  649 $1 -n|--name=<container_name>
  650 [-p|--path=<path>] [-c|--clean] [-R|--release=<CentOS_release>] [-A|--arch=<arch of the container>]
  651 [-h|--help]
  652 Mandatory args:
  653 -n,--name container name, used to as an identifier for that container from now on
  654 Optional args:
  655 -p,--path path to where the container rootfs will be created, defaults to /var/lib/lxc/name.
  656 -c,--clean clean the cache
  657 -R,--release Centos release for the new container. if the host is Centos, then it will defaultto the host's release.
  658 --fqdn fully qualified domain name (FQDN) for DNS and system naming
  659 --repo repository to use (url)
  660 -a,--arch Define what arch the container will be [i686,x86_64]
  661 -h,--help print this help
  662 EOF
  663 return 0
  664 }

テンプレートを眺めてみるとyumを使っていたので、
Debianにyumなんてあるのかなと思って調べてみたらあった。
yumをインストールしておく。

::

  % apt-get install yum

::

  % vi /var/lib/lxc/centos6-64/config
  lxc.network.type = veth
  lxc.network.flags = up
  lxc.network.link = virbr0

::

  % lxc-create -n centos6-64 -t centos -- -R 6 -a x86_64
  % lxc-start -n centos6-64 -d
  % lxc-console -n centos6-64

* https://packages.debian.org/sid/yum
