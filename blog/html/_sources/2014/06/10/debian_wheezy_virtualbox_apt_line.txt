Debian wheezy VirtualBox apt-line 設定
==================================================================



.. author:: default
.. categories:: virtualbox
.. tags:: debian, wheezy, virtualbox
.. comments::

更新のたびにdebパッケージをダウンロードしてインストールするのは面倒なので
VirtualBoxが公開しているapt-lineを設定して、apt-get(8)できるようにした。

::

  $ uname -a
  Linux zinrai 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2 x86_64 GNU/Linux

  $ cat /etc/debian_version
  7.5

::

  % vi /etc/apt/sources.list
  # virtualbox
  deb http://download.virtualbox.org/virtualbox/debian wheezy contrib


::

  % wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -


::

  % apt-get update
  % apt-get install virtualbox4.3


* https://www.virtualbox.org/wiki/Linux_Downloads
