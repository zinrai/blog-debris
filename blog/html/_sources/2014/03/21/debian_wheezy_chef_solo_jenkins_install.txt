Chef SoloでJenkinsをインストール
==============================================================================



.. author:: default
.. categories:: chef
.. tags:: debian, wheezy, chef, jenkins
.. comments::


社内で詳しい人の助けを借りてChef SoloでJenkinsをインストールしてみた。

Vagrant
------------------------------

今回は「 :doc:`../20/debian_wheezy_virtualbox_vagrant` 」で追加したBOXを使う。

::

  $ vi Vagrantfile

  # -*- mode: ruby -*-
  # vi: set ft=ruby :

  Vagrant.configure("2") do |config|
    config.vm.hostname = "jenkins"
    config.vm.box = "opscode_centos-6.4"

    config.vm.network :private_network, ip: "192.168.11.11"
    config.vm.network :forwarded_port, guest: 8080, host: 8080

    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end

    #config.omnibus.chef_version = "11.10.4"
  end

vagrant-omnibusプラグイン使えば、Vagrantの管理下にある仮想マシンに
指定したversionのChef Soloをインストールすることができるが、
ここではvagrant-omnibusは使わず別の方法でChef Soloを仮想マシンにインストールする。

::

  $ vagrant ssh-config --host jenkins >> ~/.ssh/config

Chef Solo
------------------------------

Chef SoloはDebianで動かした。

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

  % apt-get install libxml2-dev libxslt1-dev build-essential openssh-client rsync

::

  $ ruby -v
  ruby 2.0.0p353 (2013-11-22 revision 43784) [x86_64-linux]

Gemfile
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ bundle install --path vendor/bundle

::

  $ vi Gemfile
  source 'https://rubygems.org'

  gem 'berkshelf'
  gem 'chef'
  gem 'knife-solo'
  gem 'rake'

.. csv-table::
    :widths: 20,100

    berkshelf,cookbooksの依存関係を管理してくれるツール
    knife-solo,ホストのrecipeをサーバへrsyncしChef Soloを実行。結果をホストに出力してくれるknifeプラグイン

Gemfile.lock
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

2014/03/20の時点でのGemfile.lockは以下のようになっている。

::

  $ cat Gemfile.lock
  GEM
    remote: https://rubygems.org/
    specs:
      activesupport (3.2.17)
        i18n (~> 0.6, >= 0.6.4)
        multi_json (~> 1.0)
      addressable (2.3.5)
      akami (1.2.1)
        gyoku (>= 0.4.0)
        nokogiri
      berkshelf (2.0.14)
        activesupport (~> 3.2.0)
        addressable (~> 2.3.4)
        buff-shell_out (~> 0.1)
        chozo (>= 0.6.1)
        faraday (~> 0.8.0)
        faraday (~> 0.8.5)
        hashie (>= 2.0.2)
        minitar (~> 0.5.4)
        rbzip2 (~> 0.2.0)
        retryable (~> 1.3.3)
        ridley (~> 1.5.0)
        solve (>= 0.5.0)
        thor (~> 0.18.0)
      buff-config (0.4.0)
        buff-extensions (~> 0.3)
        varia_model (~> 0.1)
      buff-extensions (0.5.0)
      buff-ignore (1.1.1)
      buff-ruby_engine (0.1.0)
      buff-shell_out (0.1.1)
        buff-ruby_engine (~> 0.1.0)
      builder (3.2.2)
      celluloid (0.14.1)
        timers (>= 1.0.0)
      celluloid-io (0.14.1)
        celluloid (>= 0.14.1)
        nio4r (>= 0.4.5)
      chef (11.10.4)
        chef-zero (~> 1.7, >= 1.7.2)
        diff-lcs (~> 1.2, >= 1.2.4)
        erubis (~> 2.7)
        highline (~> 1.6, >= 1.6.9)
        json (>= 1.4.4, <= 1.8.1)
        mime-types (~> 1.16)
        mixlib-authentication (~> 1.3)
        mixlib-cli (~> 1.4)
        mixlib-config (~> 2.0)
        mixlib-log (~> 1.3)
        mixlib-shellout (~> 1.3)
        net-ssh (~> 2.6)
        net-ssh-multi (~> 1.1)
        ohai (~> 6.0)
        pry (~> 0.9)
        puma (~> 1.6)
        rest-client (>= 1.0.4, < 1.7.0)
        yajl-ruby (~> 1.1)
      chef-zero (1.7.3)
        hashie (~> 2.0)
        json
        mixlib-log (~> 1.3)
        moneta (< 0.7.0)
        rack
      chozo (0.6.1)
        activesupport (>= 3.2.0)
        hashie (>= 2.0.2)
        multi_json (>= 1.3.0)
      coderay (1.1.0)
      diff-lcs (1.2.5)
      erubis (2.7.0)
      faraday (0.8.9)
        multipart-post (~> 1.2.0)
      ffi (1.9.3)
      gssapi (1.0.3)
        ffi (>= 1.0.1)
      gyoku (1.1.1)
        builder (>= 2.1.2)
      hashie (2.0.5)
      highline (1.6.21)
      hitimes (1.2.1)
      httpclient (2.3.4.1)
      httpi (0.9.7)
        rack
      i18n (0.6.9)
      ipaddress (0.8.0)
      json (1.8.1)
      knife-solo (0.4.1)
        chef (>= 10.12)
        erubis (~> 2.7.0)
        net-ssh (>= 2.2.2, < 3.0)
      little-plugger (1.1.3)
      logging (1.8.2)
        little-plugger (>= 1.1.3)
        multi_json (>= 1.8.4)
      method_source (0.8.2)
      mime-types (1.25.1)
      mini_portile (0.5.2)
      minitar (0.5.4)
      mixlib-authentication (1.3.0)
        mixlib-log
      mixlib-cli (1.4.0)
      mixlib-config (2.1.0)
      mixlib-log (1.6.0)
      mixlib-shellout (1.3.0)
      moneta (0.6.0)
      multi_json (1.9.2)
      multipart-post (1.2.0)
      net-http-persistent (2.9.4)
      net-ssh (2.8.0)
      net-ssh-gateway (1.2.0)
        net-ssh (>= 2.6.5)
      net-ssh-multi (1.2.0)
        net-ssh (>= 2.6.5)
        net-ssh-gateway (>= 1.2.0)
      nio4r (1.0.0)
      nokogiri (1.6.1)
        mini_portile (~> 0.5.0)
      nori (1.1.5)
      ohai (6.20.0)
        ipaddress
        mixlib-cli
        mixlib-config
        mixlib-log
        mixlib-shellout
        systemu (~> 2.5.2)
        yajl-ruby
      pry (0.9.12.6)
        coderay (~> 1.0)
        method_source (~> 0.8)
        slop (~> 3.4)
      puma (1.6.3)
        rack (~> 1.2)
      rack (1.5.2)
      rake (10.1.1)
      rbzip2 (0.2.0)
      rest-client (1.6.7)
        mime-types (>= 1.16)
      retryable (1.3.5)
      ridley (1.5.3)
        addressable
        buff-config (~> 0.2)
        buff-extensions (~> 0.3)
        buff-ignore (~> 1.1)
        buff-shell_out (~> 0.1)
        celluloid (~> 0.14.0)
        celluloid-io (~> 0.14.0)
        erubis
        faraday (>= 0.8.4)
        hashie (>= 2.0.2)
        json (>= 1.7.7)
        mixlib-authentication (>= 1.3.0)
        net-http-persistent (>= 2.8)
        net-ssh
        nio4r (>= 0.5.0)
        retryable
        solve (>= 0.4.4)
        varia_model (~> 0.1)
        winrm (~> 1.1.0)
      rubyntlm (0.1.1)
      savon (0.9.5)
        akami (~> 1.0)
        builder (>= 2.1.2)
        gyoku (>= 0.4.0)
        httpi (~> 0.9)
        nokogiri (>= 1.4.0)
        nori (~> 1.0)
        wasabi (~> 1.0)
      slop (3.5.0)
      solve (0.8.2)
      systemu (2.5.2)
      thor (0.18.1)
      timers (2.0.0)
        hitimes
      uuidtools (2.1.4)
      varia_model (0.3.2)
        buff-extensions (~> 0.2)
        hashie (>= 2.0.2)
      wasabi (1.0.0)
        nokogiri (>= 1.4.0)
      winrm (1.1.3)
        gssapi (~> 1.0.0)
        httpclient (~> 2.2, >= 2.2.0.2)
        logging (~> 1.6, >= 1.6.1)
        nokogiri (~> 1.5)
        rubyntlm (~> 0.1.1)
        savon (= 0.9.5)
        uuidtools (~> 2.1.2)
      yajl-ruby (1.2.0)

  PLATFORMS
    ruby

  DEPENDENCIES
    berkshelf
    chef
    knife-solo
    rake

cookbookの作成にはいっていくが、その前にサーバにChef Soloをインストールしておく。
vagrant-omnibusではVagrantの管理下にあるマシンにしかChef Soloをインストールできないが、
knife solo prepareを使えば指定したサーバにChef Soloをインストールすることができる。

::

  $ bundle exec knife solo prepare jenkins

ディレクトリの構成は

.. csv-table::
    :widths: 20,100

    cookbooks, サードパーティのcookbooksを格納
    site-cookbooks, 自分で作成したcookbooksを格納

と使い分けるのがモダンなやり方のようだ。

::

  $ vi Berksfile

  site :opscode

  cookbook "yum", "3.0.6"
  cookbook "jenkins", path: "./site-cookbooks/jenkins"

Berksfileとsite-cookbooksは必ず一致させておく。

::

  $ bundle exec knife cookbook create jenkins -o ./site-cookbooks/
  $ bundle exec berks install --path ./cookbooks

berkshelfでcookbookを管理している場合は、site-cookbooks以下に変更を加えたら必ずberks installを実行する。

* **Node**: Chefで管理するサーバ/マシン
* **Cookbook**: Node対して行うオペレーションをまとめた単位

  * **Recipe**: Nodeに対して行うオペレーション
  * **Attribute**: cookbook内にあるパラメータ
  * **Resource**: オペレーションを抽象化したAPI

今回だと、RecipeにはJenkinsのrpmパッケージを取得してインストールして起動するまでをResourceを使って書き、
Attributeには取得先のURLとパッケージバーションをパラメータとして設定して、これらがCookbookになっているという感じである。
attributeにパラメータを設定して、recipeにオペレーションを書いて、nodes/jenkins.jsonに適用したいrecipeを書いて、
Chef Soloを実行するまでが一連の流れになる。

::

  $ vi site-cookbooks/jenkins/attributes/default.rb
  default['jenkins']['rpm'] = "jenkins-1.555-1.1.noarch.rpm"
  default['jenkins']['rpm_url'] = "http://pkg.jenkins-ci.org/redhat/#{node['jenkins']['rpm']}"

::

  $ vi sites-cookbooks/jenkins/recipe/default.rb
  %w(java-1.7.0-openjdk).each do |pkg|
    package pkg do
      action :install
    end
  end

  remote_file "/tmp/" + node["jenkins"]["rpm"] do
    source node["jenkins"]["rpm_url"]
    owner "root"
    group "root"
    mode "0755"
  end

  package "jenkins" do
    action :install
    source "/tmp/" + node["jenkins"]["rpm"]
  end

  service "jenkins" do
    action [:enable, :start]
  end

::

  $ vi nodes/jenkins.json
  {"run_list":[
      "recipe[jenkins]"
    ]
  }

::

  $ bundle exec berks install --path ./cookbooks
  $ bundle exec knife solo cook jenkins nodes/jenkins.json

最後のコマンドはjenkinsというサーバに対してnodes/jenkins.jsonに書かれた情報をもとにrecipeを適用するという意味である。

* http://berkshelf.com/
* http://docs.opscode.com/chef/resources.html
* http://docs.opscode.com/chef_overview_attributes.html
* http://pkg.jenkins-ci.org/redhat/
