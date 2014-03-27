serverspecを使ってみる
==============================================================



.. author:: default
.. categories:: serverspec
.. tags:: debian, wheezy, serverspec, chef
.. comments::

* :doc:`../22/debian_wheezy_chef_solo_vsftpd_install`

で構築した環境をserverspecを使ってテストしてみる。

vsftpdのテスト項目
----------------------------------------

* インストールされているか
* 自動起動は設定されているか
* 起動しているか
* ポート21番でListenしているか
* vsftpd.confファイルは存在するか
* vsftpd.confファイルはChefに書いてあるpermissionになっているか(600)
* vsftpd.confファイルはChefに書いてあるownerになっているか(root)
* vsftpd.confファイルはChefに書いてあるgroupになっているか(root)
* vsftpd.confにanon_root=/var/vsftpdは設定されているか
* anon_rootで指定しているディレクトリは存在するか(/var/vsftpd)
* anon_rootで指定しているディレクトリはChefに書いてあるpermissionになっているか(755)
* anon_rootで指定しているディレクトリはChefに書いてあるownerになっているか(root)
* anon_rootで指定しているディレクトリはChefに書いてあるgroupになっているか(root)

の13項目をテストする。

serverspec
----------------------------------------

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

  $ vi Gemfile
  source 'https://rubygems.org'

  gem 'serverspec'

::

  $ bundle install --path vendor/bundle

::

  $ cat Gemfile.lock
  GEM
    remote: https://rubygems.org/
    specs:
      serverspec (0.16.0)
        highline
        net-ssh
        rspec (~> 2.13)
        specinfra (>= 0.7.1)

::

  $ bundle exec serverspec-init

::

  $ vi spec/vsftpd/vsftpd_spec.rb
  require 'spec_helper'

  describe package('vsftpd') do
    it { should be_installed }
  end

  describe service('vsftpd') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(21) do
    it { should be_listening }
  end

  describe file('/etc/vsftpd/vsftpd.conf') do
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /anon_root=\/var\/vsftpd/ }
  end

  describe file('/var/vsftpd') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

::

  $ bundle exec rake spec
  /home/hoge/.rbenv/versions/2.0.0-p353/bin/ruby -S rspec spec/vsftpd/vsftpd_spec.rb
  .............

  Finished in 1.17 seconds
  13 examples, 0 failures

日本語で長々と書いていたものが、Resourceを指定してResourceが持っているマッチャーを使い
should be_hogehoge argと書けば表現できていい感じ。

* http://serverspec.org/
* http://serverspec.org/tutorial.html
* http://serverspec.org/resource_types.html
