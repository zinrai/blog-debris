Debian sid で vagrant-kvm を使ってみた
============================================



.. author:: default
.. categories:: vagrant
.. tags:: debian, sid, vagrant, kvm
.. comments::

Vagrant KVM Providerであるvagrant-kvmを使ってみた。
ruby-libvirt(gem)をビルドするのにruby2.0-devが必要になる。
ruby2.0-devはtesting,unstableにしか存在しなかったのでsidを使った。
vagrant-kvm用に作られたboxを使ってvagrant upするところまではやってみた。

::

  $ uname -srv
  Linux 3.14-1-amd64 #1 SMP Debian 3.14.7-1 (2014-06-16)

  $ cat /etc/debian_version
  jessie/sid

::

  % apt-get install -y qemu qemu-kvm libvirt-bin
  % apt-get install -y nfs-kernel-server nfs-common rpcbind
  % apt-get install -y redir dnsmasq-base bridge-utils
  % apt-get install -y build-essential libxml2-dev libxslt1-dev libvirt-dev ruby2.0-dev

::

  % gpasswd -a zinrai libvirt

::

  $ wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
  % dpkg -i vagrant_1.6.3_x86_64.deb

::

  % wget https://vagrant-kvm-boxes.s3.amazonaws.com/precise64-kvm.box

::

  $ vagrant plugin install vagrant-kvm

::

  $ wget https://vagrant-kvm-boxes.s3.amazonaws.com/precise64-kvm.box
  $ vagrant box add precise64 precise64-kvm.box

  $ vagrant box list
  precise64 (kvm, 0)

::

  $ mkdir precise64
  $ cd precise64
  $ vagrant init precise64
  $ vagrant up

特にハマることなく動いた。
Vagrantfileについてはまた後日。

* http://www.vagrantup.com/
* https://github.com/adrahon/vagrant-kvm
* https://github.com/adrahon/vagrant-kvm/wiki/List-boxes
* https://github.com/adrahon/vagrant-kvm/blob/master/INSTALL.md
