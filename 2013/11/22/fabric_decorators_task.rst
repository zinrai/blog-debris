Fabric decorators task
============================================



.. author:: default
.. categories:: fabric
.. tags:: python, fabric
.. comments::

* :doc:`../../07/20/freebsd_pxeboot`
* :doc:`../../09/07/debian_wheezy_pxeboot`
* :doc:`../../09/08/gentoo_install_script`
* :doc:`../../10/24/debian_wheezy_dnsmasq_proxy_dhcp`
* :doc:`../../10/26/centos_diskless`
* :doc:`../../11/01/freebsd_mfsbsd`

シェルスクリプトでLinuxをインストールする環境はできたが、
サーバに接続してシェルスクリプトをコピー・編集するという状態である。
Fabricを使いこの作業をホストから行えるようにしてみる。
fabfile.pyひとつにタスクを書いていくのではなくディストリビューションやOSごとに
ファイルを分割してタスクを書いていく。

::

  $ python -V
  Python 2.7.3

  $ fab --version
  Fabric 1.8.0
  Paramiko 1.12.0


::

  $ mkdir fabfile
  $ cd fabfile
  $ touch __init__.py centos.py debian.py freebsd.py gentoo.py

::

  $ vi __init__.py

  from . import debian
  from . import centos
  from . import gentoo
  from . import freebsd


::

  $ vi centos.py

  from fabric.decorators import task

  @task
  def cmd():
      pass


::

  $ vi debian.py

  from fabric.decorators import task

  @task
  def cmd():
      pass


::

  $ vi gentoo.py

  from fabric.decorators import task

  @task
  def cmd():
      pass


::

  $ vi freebsd.py

  from fabric.decorators import task

  @task
  def cmd():
      pass


::

  $ fab -l
  Available commands:

      centos.cmd
      debian.cmd
      freebsd.cmd
      gentoo.cmd


* http://docs.fabfile.org/en/1.8/
* http://docs.fabfile.org/en/1.8/api/core/decorators.html
* https://speakerdeck.com/drillbits/fabric-python-developers-festa-2013-dot-03-number-pyfes
