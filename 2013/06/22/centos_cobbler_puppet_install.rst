Cobbler + Puppet
###############################################################



.. author:: default
.. categories:: centos,puppet,cobbler
.. tags:: centos,puppet,cobbler
.. comments::


前回はCobblerでとりあえずOSインストールが出来るところまでやったので、
今回はkickstartファイルの編集、Puppet(Puppet client)のインストールとセットアップを自動化してみる。

dnsmasq
***************************************************************

DHCP,DNSサーバにdnsmasqを使用する。ISC DHCPよりもdnsmasqを使ったほうがPuppetと連携させやすいことに気が付いた。


::

  # vi /etc/cobbler/settings

  manage_dns: 1
  manage_dhcp: 1
  server: 192.168.0.1
  next_server: 192.168.0.1


::

  # vi /etc/cobbler/modules.conf

  [dns]
  module = manage_dnsmasq

  [dhcp]
  module = manage_dnsmasq

::

  # yum install dnsmasq


::

  # vi /etc/cobbler/dnsmasq.template

  # Cobbler generated configuration file for dnsmasq
  # $date
  #

  # resolve.conf .. ?
  #no-poll
  #enable-dbus
  read-ethers
  addn-hosts = /var/lib/cobbler/cobbler_hosts

  dhcp-range=192.168.0.220,192.168.0.250
  dhcp-option=3,$next_server
  dhcp-lease-max=1000
  dhcp-authoritative
  dhcp-boot=pxelinux.0
  dhcp-boot=net:normalarch,pxelinux.0
  dhcp-boot=net:ia64,$elilo

  $insert_cobbler_system_definitions


::

  # chkconfig dnsmasq on
  # service dnsmasq start
  # service cobblerd restart
  # cobbler sync


Cobbler
***************************************************************

::

  # cobbler profile report
  Name                           : CentOS6.4-x86_64
  TFTP Boot Files                : {}
  Comment                        :
  DHCP Tag                       : default
  Distribution                   : CentOS6.4-x86_64
  Enable gPXE?                   : 0
  Enable PXE Menu?               : 1
  Fetchable Files                : {}
  Kernel Options                 : {}
  Kernel Options (Post Install)  : {}
  Kickstart                      : /var/lib/cobbler/kickstarts/sample.ks
  Kickstart Metadata             : {}
  Management Classes             : []
  Management Parameters          : <<inherit>>
  Name Servers                   : []
  Name Servers Search Path       : []
  Owners                         : ['admin']
  Parent Profile                 :
  Proxy                          :
  Red Hat Management Key         : <<inherit>>
  Red Hat Management Server      : <<inherit>>
  Repos                          : []
  Server Override                : <<inherit>>
  Template Files                 : {}
  Virt Auto Boot                 : 1
  Virt Bridge                    : xenbr0
  Virt CPUs                      : 1
  Virt Disk Driver Type          : raw
  Virt File Size(GB)             : 5
  Virt Path                      :
  Virt RAM (MB)                  : 512
  Virt Type                      : qemu


登録しているprofileからPuppet Server,Puppet Clientのprofileを作成する。

::

  # cobbler profile copy --name=CentOS6.4-x86_64 --newname=CentOS6.4-puppet_server
  # cobbler profile copy --name=CentOS6.4-x86_64 --newname=CentOS6.4-puppet_client


EPELにあるPuppetを使用する。

::

  # yum -y install wget

  # cobbler repo add --name=CentOS6.4-epel --mirror=http://dl.fedoraproject.org/pub/epel/6/x86_64/ --mirror-locally=N --breed=yum
  # cobbler reposync

  # cobbler repo report
  Name                           : CentOS6.4-epel
  Arch                           : x86_64
  Breed                          : yum
  Comment                        :
  Createrepo Flags               : <<inherit>>
  Environment Variables          : {}
  Keep Updated                   : True
  Mirror                         : http://dl.fedoraproject.org/pub/epel/6/x86_64
  Mirror locally                 : False
  Owners                         : ['admin']
  Priority                       : 99
  RPM List                       : []
  Yum Options                    : {}


profileにリポジトリの情報を追加


::

  # cobbler profile edit --name=CentOS6.4-puppet_server --repos="CentOS6.4-epel"
  # cobbler profile edit --name=CentOS6.4-puppet_client --repos="CentOS6.4-epel"


profileをコピーしたままの状態ではsample.ksファイルが読み込まれるので、
ksファイルをコピーしてPuppetをインストールするよう書き換える。

::

  # cd /var/lib/cobbler/kickstarts
  # cp sample.ks puppet_server.ks
  # cp sample.ks puppet_client.ks

  # cobbler profile edit --name=CentOS6.4-puppet_cli --kickstart=/var/lib/cobbler/kickstarts/puppet_server.ks
  # cobbler profile edit --name=CentOS6.4-puppet_cli --kickstart=/var/lib/cobbler/kickstarts/puppet_client.ks

固定IPを割り振るためにsystemに登録する。

::

  # vi /etc/cobbler/settings
  pxe_just_once: 1

  # service cobblerd restart


::

  # cobbler system add  \
  --name=puppet-server-2 \
  --hostname=puppetserver.localnet \
  --dns-name=puppetserver.localnet \
  --profile=CentOS6.4-puppet_server \
  --interface=eth0 \
  --mac=XX:XX:XX:XX:XX:XX \
  --static=1 \
  --ip-address=192.168.0.2 \
  --subnet=255.255.255.0 \
  --gateway=192.168.0.254 \
  --name-servers=192.168.0.1

  # cobbler system add  \
  --name=puppet-client-003 \
  --hostname=puppetclient003.localnet \
  --dns-name=puppetclient003.localnet \
  --profile=CentOS6.4-puppet_client \
  --interface=eth0 \
  --mac=XX:XX:XX:XX:XX:XX \
  --static=1 \
  --ip-address=192.168.0.3 \
  --subnet=255.255.255.0 \
  --gateway=192.168.0.254 \
  --name-servers=192.168.0.1


pxe_just_onceを有効にすると登録したsystemは1度しかpxe bootしないので、
OSインストール後に、もう1度pxe bootさせたくなったら下記を実行する。

::

  # cobbler system edit --name=puppet-client-003 --netboot-enabled=1


Puppet
***************************************************************

PuppetにはPUSHモードとPULLモードがある。

.. csv-table::
  :header-rows: 0
  :widths: 1,6

  PULL,クライアントからサーバへ定期的にマニュフェストを取得し適用する。
  PUSH,サーバからクライアントへマニュフェストを取得し適用するよう指示する。


今回はPUSHモードのPuppet環境を構築する。

Puppet server
---------------------------------------------------------------

Puppet clientを自動構築するためにPuppet serverを作り込む。

Puppet serverのほうはOSインストール後にPuppet serverをインストールするなり、
Cobblerサーバのkickstartファイルのpackageセクションに記述するなり好きにすればいいと思う。

::

  # puppet --version
  2.6.18

::

  # vi /etc/sysconfig/puppet

  # The puppetmaster server
  #PUPPET_SERVER=puppet

  # If you wish to specify the port to connect to do so here
  PUPPET_PORT=8139

  # Where to log to. Specify syslog to send log messages to the system log.
  PUPPET_LOG=/var/log/puppet/puppet.log

  # You may specify other parameters to the puppet client here
  #PUPPET_EXTRA_OPTS=--waitforcert=500


::

  # vi /etc/puppet/autosign.conf

  *.localnet

::

  # vi /etc/puppet/fileserver.conf

  [files]
   path /etc/puppet/manifests/files
   allow *


::

  # vi /etc/puppet/manifests/site.pp

  package { 'zsh' :
          ensure => present;
  }

  file { '/etc/sysconfig/puppet' :
          owner => 'root',
          group => 'root',
          mode => 644,
          source => 'puppet://puppetserver.localnet/files/puppet',
  }

  file { '/etc/puppet/auth.conf' :
          owner => 'root',
          group => 'root',
          mode => 644,
          source => 'puppet://puppetserver.localnet/files/auth.conf',
  }


::

  # vi /etc/puppet/manifests/files/puppet

  # The puppetmaster server
  PUPPET_SERVER=puppetsrv.localnet

  # If you wish to specify the port to connect to do so here
  #PUPPET_PORT=8140

  # Where to log to. Specify syslog to send log messages to the system log.
  PUPPET_LOG=/var/log/puppet/puppet.log

  # You may specify other parameters to the puppet client here
  #PUPPET_EXTRA_OPTS=--waitforcert=500
  PUPPET_EXTRA_OPTS="--listen --no-client"


::

  # vi /etc/puppet/manifests/files/auth.conf

  path /run
  method save
  allow *

  path /
  auth any

::

  # service puppetmaster start


これで以下のコマンドを実行すればPuppet clientにマニュフェストが適用される。

::

  # puppet kick --host puppetclient002.localnet


Kickstart
***************************************************************

Puppet client用のkickstartファイルは下記のようになっている。

postセクションに

::

  /sbin/chkconfig puppet on
  puppet agent --server=puppetserver.localnet --no-daemonize --onetime

を記述することで、Puppetの自動起動、Puppet serverからマニュフェストを取得する処理が1度だけ実行される。
これでPuppet clientはOSインストールからPuppetインストール,セットアップまで自動化することが出来た。
しかし、今回の設定では各clientの細かい制御(client1にはapache,client2にはmysqlなど)が出来ていないのでそれについては、またの機会に書きたいと思う。

::

  # vi /var/lib/cobbler/kickstarts/puppet_client.ks

  #platform=x86, AMD64, or Intel EM64T
  # System authorization information
  auth  --useshadow  --enablemd5
  # System bootloader configuration
  bootloader --location=mbr
  # Partition clearing information
  clearpart --all --initlabel
  # Use text mode install
  text
  # Firewall configuration
  #firewall --enabled
  firewall --disabled
  # Run the Setup Agent on first boot
  firstboot --disable
  # Timezone
  timezone Asia/Tokyo
  # System keyboard
  keyboard us
  # System language
  lang en_US
  # Use network installation
  url --url=$tree
  # If any cobbler repo definitions were referenced in the kickstart profile, include them here.
  $yum_repo_stanza
  # Network information
  $SNIPPET('network_config')
  # Reboot after installation
  reboot

  #Root password
  rootpw --iscrypted $default_password_crypted
  # SELinux configuration
  selinux --disabled
  # Do not configure the X Window System
  skipx
  # System timezone
  timezone  America/New_York
  # Install OS instead of upgrade
  install
  # Clear the Master Boot Record
  zerombr
  # Allow anaconda to partition the system as needed
  autopart


  %pre
  $SNIPPET('log_ks_pre')
  $SNIPPET('kickstart_start')
  $SNIPPET('pre_install_network_config')
  # Enable installation monitoring
  $SNIPPET('pre_anamon')

  %packages
  $SNIPPET('func_install_if_enabled')
  $SNIPPET('puppet_install_if_enabled')
  puppet

  %post
  $SNIPPET('log_ks_post')
  # Start yum configuration
  $yum_config_stanza
  # End yum configuration
  $SNIPPET('post_install_kernel_options')
  $SNIPPET('post_install_network_config')
  $SNIPPET('func_register_if_enabled')
  $SNIPPET('puppet_register_if_enabled')
  $SNIPPET('download_config_files')
  $SNIPPET('koan_environment')
  $SNIPPET('redhat_register')
  $SNIPPET('cobbler_register')
  /sbin/chkconfig puppet on
  puppet agent --server=puppetserver.localnet --no-daemonize --onetime
  # Enable post-install boot notification
  $SNIPPET('post_anamon')
  # Start final steps
  $SNIPPET('kickstart_done')
  # End final steps



* http://d.hatena.ne.jp/int128/20120226/1330247800
* http://blog.glidenote.com/blog/2012/03/16/cobbler-system-add/
* http://www.cobblerd.org/manuals/2.4.0/4/4/2_-_Managing_DNS.html
* http://www.cobblerd.org/manuals/2.2.3/4/3/1_-_Managing_DHCP.html
