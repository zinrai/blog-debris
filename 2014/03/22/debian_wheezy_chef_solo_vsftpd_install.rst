Chef Soloでvsftpdのインストールと設定
============================================================================



.. author:: default
.. categories:: chef
.. tags:: debian, wheezy, chef, vsftpd
.. comments::

* 某スイッチのアップグレードのためにFTPサーバを立てなければいけなくて、vsftpdでanonymous FTPのディレクトリを設定するのに手間取ったのでメモしておきたい。
* :doc:`前回 <../21/debian_wheezy_chef_solo_jenkins_install>` はTemplate Resourceを使わなかったので使ってみたい。

ということでChef Soloでvsftpdをインストール、Template Resource使った設定ファイルの設置まで行う。

:doc:`前回 <../21/debian_wheezy_chef_solo_jenkins_install>` と同じくVagrantを使う。
作ったCookbookは `Github <https://github.com/zinrai/chef-repo/tree/vsftpd>`_ に置くようにした。

Vagrant
------------------------------

::

  $ vagrant -v
  Vagrant 1.4.3

::

  $ vi Vagrantfile

  # -*- mode: ruby -*-
  # vi: set ft=ruby :

  Vagrant.configure("2") do |config|
    config.vm.hostname = "vsftpd"
    config.vm.box = "opscode_centos-6.4"

    config.vm.network :public_network, :ip => "192.168.0.1", :netmask => "255.255.255.0", :bridge => "eth0"
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

今回はforward portではなくbridgeするようにした。

::

  $ vagrant up
  $ vagrant ssh-config --host vsftpd >> ~/.ssh/config

vsftpd
------------------------------

::

  $ cat /etc/centos-release
  CentOS release 6.4 (Final)

::

  $ man -k vsftpd
  vsftpd               (8)  - Very Secure FTP Daemon
  vsftpd.conf [vsftpd] (5)  - config file for vsftpd

  $ man vsftpd.conf

  anon_root
                This option represents a directory which vsftpd will try to change into after  an
                anonymous login. Failure is silently ignored.

                Default: (none)


anonymous FTPは有効になっているけれどディレクトリは設定されていないのでanon_rootを設定する。

::

  $ vsftpd -v
  vsftpd: version 2.2.2

::

  $ cat /etc/vsftpd.conf.org
  anonymous_enable=YES
  local_enable=YES
  write_enable=YES
  local_umask=022
  dirmessage_enable=YES
  xferlog_enable=YES
  connect_from_port_20=YES
  xferlog_std_format=YES
  listen=YES
  pam_service_name=vsftpd
  userlist_enable=YES
  tcp_wrappers=YES

::

  $ diff -u vsftpd.conf vsftpd.conf.org
  --- vsftpd.conf 2014-03-22 09:37:23.935013981 +0000
  +++ vsftpd.conf.org     2014-03-22 09:10:03.970016338 +0000
  @@ -1,5 +1,4 @@
   anonymous_enable=YES
  -anon_root=/var/vsftpd
   local_enable=YES
   write_enable=YES
   local_umask=022

Chef Solo
------------------------------

anon_rootの設定を追加してanonymous FTP用のディレクトリを作成すればいいということがわかったのでCookbookに落し込んでいく。

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

::

  $ bundle exec knife solo prepare vsftpd

::

  $ vi Berksfile

  site :opscode

  cookbook "yum", "3.0.6"
  cookbook "vsftpd", path: "./site-cookbooks/vsftpd"

::

  $ bundle exec knife cookbook create vsftpd -o ./site-cookbooks
  $ bundle exec berks install --path ./cookbooks

::

  $ vi site-cookbooks/vsftpd/recipes/default.rb
  %w(vsftpd).each do |pkg|
    package pkg do
      action :install
    end
  end

  directory '/var/vsftpd' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  template "vsftpd.conf" do
    path "/etc/vsftpd/vsftpd.conf"
    source "vsftpd.conf.erb"
    owner "root"
    group "root"
    mode "600"
  end

  service "vsftpd" do
    action [:enable, :start]
  end

::

  $ vi site-cookbooks/vsftpd/templates/default/vsftpd.conf.erb
  anonymous_enable=YES
  anon_root=/var/vsftpd
  local_enable=YES
  write_enable=YES
  local_umask=022
  dirmessage_enable=YES
  xferlog_enable=YES
  connect_from_port_20=YES
  xferlog_std_format=YES
  listen=YES
  pam_service_name=vsftpd
  userlist_enable=YES
  tcp_wrappers=YES

::

  $ vi nodes/vsftpd.json
  {"run_list":[
      "recipe[vsftpd]"
    ]
  }

::

  $ bundle exec berks install --path ./cookbooks
  $ bundle exec knife solo cook vsftpd nodes/vsftpd.json

::

  $ ftp 192.168.0.1

などしてFTPサーバにアクセスできれば成功している。

* http://docs.opscode.com/resource_directory.html
* http://docs.opscode.com/resource_template.html
* http://docs.vagrantup.com/v2/networking/public_network.html
