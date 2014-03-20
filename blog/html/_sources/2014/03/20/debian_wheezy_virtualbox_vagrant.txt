Debian wheezyでVagrantを使てみた
================================================================



.. author:: default
.. categories:: vagrant
.. tags:: deiban, wheezy, vagrant, virtualbox
.. comments::

巷で人気のVagrantで

* BOXの追加
* 仮想マシンの起動
* プラグインのインストール
* インストールしたプラグインの使用

までやってみた。

::

  $ uname -a
  Linux hoge 3.2.0-4-amd64 #1 SMP Debian 3.2.54-2 x86_64 GNU/Linux

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.4 (wheezy)
  Release:        7.4
  Codename:       wheezy

Virtualbox
------------------------------

インストール
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ wget http://download.virtualbox.org/virtualbox/4.3.8/virtualbox-4.3_4.3.8-92456~Debian~wheezy_amd64.deb
  % dpkg -i virtualbox*.deb

Vagrant
------------------------------

インストール
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.5.1_x86_64.deb
  % dpkg -i vagrant*.deb

BOXの追加
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

今回はopscodeが公開しているBOXを使う。

::

  $ wget http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.4_chef-provisionerless.box

  $ vagrant box add opscode_centos-6.4 opscode_centos-6.4_chef-provisionerless.box
  $ vagrant box list
  opscode_centos-6.4 (virtualbox)

仮想マシンの起動
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ vi Vagrantfile

  # -*- mode: ruby -*-
  # vi: set ft=ruby :

  Vagrant.configure("2") do |config|
    config.vm.hostname = "test"
    config.vm.box = "opscode_centos-6.4"

    config.vm.network :private_network, ip: "192.168.11.11"
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

::

  $ vagrant up

sahara
----------------------------

Vagrantで管理されている仮想マシンのある時点の状態を保存しておき
ロールバックしたりすることができるプラグイン

::

  $ vagrant plugin install sahara
  $ vagrant plugin list
  sahara (0.0.16)

インストールするとVagrantにサブコマンドsandboxが追加される。

::

  $ vagrant sandbox -h
  Usage: vagrant plugin <command> [<args>]

  Available subcommands:
       commit
       off
       on
       rollback
       status

.. csv-table::
    :widths: 10, 70

    commit, 保存されて状態以降の変更を保存する。
    off, sandboxをoffにする。保存されちている状態以降の変更は保存される。
    on, onにした時点の仮想マシンの状態が保存される。
    rollback, 最後に保存した時点までロールバックする。
    status, sandbox状態かの確認

::

  $ vagrant status
  Current machine states:

  default                   running (virtualbox)

  $ vagrant sandbox status
  [default] Sandbox mode is off

  $ vagrant sandbox commit
  $ vagrant sandbox off
  $ vagrant sandbox on
  $ vagrant sandbox rollback

sandboxをonにしてVagrantで管理している仮想マシンにアクセスして変更を加えたあとrollbackすると仮想マシンがon時の状態に戻る。

* http://www.vagrantup.com/
* http://opscode.github.io/bento/
* https://github.com/jedi4ever/sahara
* https://www.virtualbox.org/wiki/Linux_Downloads
