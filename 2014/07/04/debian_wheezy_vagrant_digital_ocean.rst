Vagrant で DigitalOcean を操作する
======================================================================



.. author:: default
.. categories:: vagrant
.. tags:: debian, wheezy, vagrant
.. comments::

グローバルIPを持ったサーバが必要になったので、DigitalOcean(VPS)を使ってみた。
APIが整備されていて、Vagrantで操作できるプラグインもあり簡単にサーバを作ったり消したりできてとても便利

::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2

  $ cat /etc/debian_version
  7.5

::

  $ vagrant version
  Installed Version: 1.6.3
  Latest Version: 1.6.3

vagrant-digitalocean
------------------------------------------

dotenvを使いapi_keyなどをVagrantfileにベタ書きしないようにする。

::

  $ vagrant plugin install vagrant-digitalocean
  $ vagrant plugin install dotenv

  $ vagrant plugin list
  dotenv (0.11.1)
  vagrant-digitalocean (0.5.5)

Vagrantfile
--------------------------------------------

::

  # -*- mode: ruby -*-
  # vi: set ft=ruby :

  Dotenv.load

  # change default provider to digital_ocean
  ENV['VAGRANT_DEFAULT_PROVIDER'] = "digital_ocean"

  # Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
  VAGRANTFILE_API_VERSION = "2"

  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.provider :digital_ocean do |provider, override|
      override.vm.hostname          = "debian-wheezy-64"
      override.vm.box               = "digital_ocean"
      override.vm.box_url           = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
      override.ssh.username         = ENV['DO_SSH_USERNAME']
      override.ssh.private_key_path = ENV['DO_SSH_KEY']
      # disable synced_folder: rsync is not installed on DigitalOcean's guest machine
      override.vm.synced_folder "./", "/vagrant", disabled: true

      provider.client_id            = ENV['DO_CLIENT_ID']
      provider.api_key              = ENV['DO_API_KEY']
      provider.region               = "Singapore 1"
      provider.image                = "Debian 7.0 x64"
      provider.size                 = "512MB"
      provider.private_networking   = true
      provider.setup                = true

      # provision
      # Do whatever you wanna do !!
    end

  end

.env
------------------------

SSH公開鍵をDigitalOceanに登録しておくこと。

::

  $ vi .env
  DO_SSH_USERNAME="zinrai"
  DO_SSH_KEY=${HOME}/.ssh/id_rsa
  DO_CLIENT_ID="1234567890"
  DO_API_KEY="abcdefghijklmn"

Vagrant
---------------------------------

::

  $ vagrant up
  Bringing machine 'default' up with 'digital_ocean' provider...
  ==> default: Using existing SSH key: Vagrant
  ==> default: Creating a new droplet...
  ==> default: Assigned IP address: 1.2.3.4
  ==> default: Private IP address: 10.1.1.1
  ==> default: Creating user account: zinrai...

  $ vagrant status
  Current machine states:

  default                   active (digital_ocean)

  active

  $ vagrant halt
  ==> default: Powering off the droplet...

  $ vagrant destroy

* https://www.digitalocean.com/
* https://github.com/bkeepers/dotenv
* https://github.com/smdahlen/vagrant-digitalocean
* http://qiita.com/msykiino/items/d45cab7f520a3288862a
