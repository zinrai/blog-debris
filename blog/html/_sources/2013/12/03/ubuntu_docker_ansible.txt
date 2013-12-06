Ansibleを使ってみる
===============================================================



.. author:: default
.. categories:: ansible
.. tags:: python, docker, ansible, ubuntu
.. comments::

* :doc:`../../11/28/ubuntu_docker`

前回はDockerの使い方を調べたので、今回はDocker上のコンテナで巷で噂の `Ansible`_ を動かしてみる。

コンテナ起動
------------------------------

::

  % docker run -i -t -id --name test01 ubuntu:latest /bin/bash
  % docker attach test01

コンテナイメージ作成
------------------------------

::

  % lsb_release -a
  No LSB modules are available.
  Distributor ID: Ubuntu
  Description:    Ubuntu 12.04 LTS
  Release:        12.04
  Codename:       precise

* Python,SSHインストール
* SSH公開鍵 設定
* sudo設定

起動したコンテナで上記の作業してコンテナイメージを作成する。

::

  % apt-get install python2.7 python2.7-dev openssh-server vim sudo wget ca-certificates

  % mkdir /var/run/sshd
  % cd /etc/ssh
  % cp sshd_config sshd_config.org
  % diff -u sshd_config.org sshd_config
  --- sshd_config.org     2013-12-05 05:51:00.924484160 +0000
  +++ sshd_config 2013-12-05 05:51:37.676483746 +0000
  @@ -29,7 +29,7 @@

   RSAAuthentication yes
   PubkeyAuthentication yes
  -#AuthorizedKeysFile    %h/.ssh/authorized_keys
  +AuthorizedKeysFile     %h/.ssh/authorized_keys

   # Don't read the user's ~/.rhosts and ~/.shosts files
   IgnoreRhosts yes
  @@ -84,4 +84,4 @@
   # If you just want the PAM account and session checks to run without
   # PAM authentication, then enable this but set PasswordAuthentication
   # and ChallengeResponseAuthentication to 'no'.
  -UsePAM yes
  +UsePAM no

  % /usr/sbin/sshd

  % useradd -m -s /bin/bash zinrai
  % usermod -a -G sudo zinrai
  % passwd zinrai

  % su - zinrai
  $ ssh-keygen
  $ cd .ssh
  $ cp id_rsa.pub authorized_keys

::

  % docker commit test01 ansible/test01
  % docker run -i -t -d --name ansible01 ansible/test01 /bin/bash
  % docker run -i -t -d --name ansible02 ansible/test01 /bin/bash

Ansible
------------------------------

* `Ansible`_ はvirtualenv上で動かす。
* --ask-sudo-passオプションが使えるようにsshpassをインストール

::

  $ wget https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.10.1.tar.gz
  $ tar zvxf virtualenv-1.10.1.tar.gz
  $ python virtualenv-1.10.1/virtualenv.py ansible
  $ source ansible/bin/activate
  $ pip install ansible
  $ pip freeze
  pip freeze
  Jinja2==2.7.1
  MarkupSafe==0.18
  PyYAML==3.10
  ansible==1.4.1
  argparse==1.2.1
  ecdsa==0.10
  paramiko==1.12.0
  pycrypto==2.6.1
  wsgiref==0.1.2

::

  % vi /etc/apt/source.list
  deb http://archive.ubuntu.com/ubuntu precise main universe
  deb-src http://archive.ubuntu.com/ubuntu/ precise main universe
  deb http://archive.ubuntu.com/ubuntu/ precise-updates main universe
  deb-src http://archive.ubuntu.com/ubuntu/ precise-updates main universe

  % apt-get update
  % apt-get install sshpass

::

  $ mkdir playbook
  $ cd playbook

::

  $ vi hosts
  [test]
  172.17.0.10
  172.17.0.11

::

  $ vi setup.yml
  ---
  - hosts: test
    remote_user: zinrai
    sudo: yes

    tasks:
    - name: Package Installed
      apt: pkg={{ item }} state=latest
      with_items:
      - less
      - perl-modules

::

  $ ansible-playbook -i hosts setup.yml --ask-sudo-pass
  sudo password:

  PLAY [test] *******************************************************************

  GATHERING FACTS ***************************************************************
  ok: [172.17.0.10]
  ok: [172.17.0.11]

  TASK: [Package Installed] *****************************************************
  changed: [172.17.0.10] => (item=less,perl-modules)
  changed: [172.17.0.11] => (item=less,perl-modules)

  PLAY RECAP ********************************************************************
  172.17.0.10                : ok=2    changed=1    unreachable=0    failed=0
  172.17.0.11                : ok=2    changed=1    unreachable=0    failed=0


.. _Ansible: http://www.ansibleworks.com/

* http://www.ansibleworks.com/docs/playbooks.html
* http://www.slideshare.net/takushimizu/ansible-26200860
