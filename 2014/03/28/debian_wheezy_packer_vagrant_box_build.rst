Packerを使ってVagrantのBOX作成
============================================================================



.. author:: default
.. categories:: packer
.. tags:: debian, wheezy, packer, vagrant, virtualbox
.. comments::

* :doc:`../21/debian_wheezy_chef_solo_jenkins_install`
* :doc:`../22/debian_wheezy_chef_solo_vsftpd_install`

ではOpscodeが配布しているBOXを使用していたが、
今回はPackerを使い自前のBOXを作成してみる。

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


Packer
------------------------------

インストール
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ wget https://dl.bintray.com/mitchellh/packer/0.5.2_linux_amd64.zip
  $ mkdir -p $HOME/opt/local/bin
  $ unzip 0.5.2_linux_amd64.zip -d 0.5.2_linux_amd64
  $ cd 0.5.2_linux_amd64
  $ mv `ls` $HOME/opt/local/bin
  $ vi .bashrc
  PATH=$HOME/opt/local/bin:$PATH
  $ . .bashrc

::

  $ packer -v
  Packer v0.5.2


テンプレート作成
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

`ryuzee / sandbox-devops <https://github.com/ryuzee/sandbox-devops>`_
にPackerのテンプレートがあったのでForkしてCentOS 6.5のテンプレートを弄ってBOXを作成してみた。
BOXの作り方は「 `Creating a Base Box <http://docs.vagrantup.com/v2/boxes/base.html>`_ 」を参考にした。

::

  $ git clone https://github.com/zinrai/sandbox-devops.git
  $ cd sandbox-devops/packer-vagrantbox/CentOS-6.5-x86_64
  $ git diff master packer_vagrantbox

::

  $ diff --git a/packer-vagrantbox/CentOS-6.5-x86_64/Vagrantfile b/packer-vagrantbox/CentOS-6.5-x86_64/Vagrantfile
  index f0c350c..d15ec59 100644
  --- a/packer-vagrantbox/CentOS-6.5-x86_64/Vagrantfile
  +++ b/packer-vagrantbox/CentOS-6.5-x86_64/Vagrantfile
  @@ -1,3 +1,3 @@
   Vagrant.configure("2") do |config|
  -    config.vm.base_mac = "{{ .BaseMacAddress }}"
  +    #config.vm.base_mac = "{{ .BaseMacAddress }}"
   end

`古い設定 <https://github.com/mitchellh/packer/commit/0f82c01b98567fbea4436fb142d5c1f21fba30ed>`_
が残っていたのでコメントアウトした。

::

  $ diff --git a/packer-vagrantbox/CentOS-6.5-x86_64/machine.json b/packer-vagrantbox/CentOS-6.5-x86_64/machine.json
  index b9418c1..76d6013 100644
  --- a/packer-vagrantbox/CentOS-6.5-x86_64/machine.json
  +++ b/packer-vagrantbox/CentOS-6.5-x86_64/machine.json
  @@ -2,7 +2,7 @@
     "builders":[{
       "type": "virtualbox-iso",
       "guest_os_type": "RedHat_64",
  -    "iso_url": "http://mozilla.ftp.iij.ad.jp/pub/linux/centos/6/isos/x86_64/CentOS-6.5-x86_64-minimal.iso",
  +    "iso_url": "http://ftp.jaist.ac.jp/pub/Linux/CentOS/6.5/isos/x86_64/CentOS-6.5-x86_64-minimal.iso",
       "iso_checksum": "0d9dc37b5dd4befa1c440d2174e88a87",
       "iso_checksum_type": "md5",
       "ssh_username": "vagrant",

iso_urlに書かれていたURLにアクセスしてみるとForbiddenだったので、変更した。

::

  $ diff --git a/packer-vagrantbox/CentOS-6.5-x86_64/virtualbox.sh b/packer-vagrantbox/CentOS-6.5-x86_64/virtualbox.sh
  index 2b6cd8c..d4dc928 100644
  --- a/packer-vagrantbox/CentOS-6.5-x86_64/virtualbox.sh
  +++ b/packer-vagrantbox/CentOS-6.5-x86_64/virtualbox.sh
  @@ -29,7 +29,3 @@ sudo sh /mnt/VBoxLinuxAdditions.run
   sudo umount /mnt
   #rm -rf /home/vagrant/VBoxGuestAdditions*.iso
   sudo /etc/rc.d/init.d/vboxadd setup
  -
  -sudo su -c "curl -L https://www.opscode.com/chef/install.sh | bash"
  -which chef-solo
  -sleep 5

Chef Soloインストールの部分は削除した。

BOX作成
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

  $ packer validate machine.json
  Template validated successfully.

::

  $ packer build machine.json

::

  $ ls
  CentOS-6.5-x86_64-ja.box  Vagrantfile  ks.cfg  machine.json  packer_cache  virtualbox.sh

::

  $ vagrant box add CentOS-6.5-x86_64-ja CentOS-6.5-x86_64-ja.box
  $ vagrant box list
  CentOS-6.5-x86_64-ja (virtualbox)

::

  $ mkdir centos65
  $ cd centos65
  $ vagrant init CentOS-6.5-x86_64-ja
  $ vagrant up

* http://www.packer.io/
* https://github.com/ryuzee/sandbox-devops
* http://docs.vagrantup.com/v2/boxes/base.html
