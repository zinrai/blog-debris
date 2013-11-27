Fabric テンプレート アップロード
==================================================================



.. author:: default
.. categories:: fabric
.. tags:: fabric, python
.. comments::

「 :doc:`../../11/22//fabric_decorators_task` 」で
ディストリビューションやOSごとにファイルを分割してタスクを書けるようにした。
今回はインストールスルクリプトをテンプレート化してアップロードするタスクを書いてみる。

::

  $ vi __init__.py


.. literalinclude:: __init__.py
   :language: python

::

  $ vi debian.py


.. literalinclude:: debian.py
   :language: python


::

  $ mkdir templates
  $ vi templates/debian_template.conf

.. literalinclude:: debian_template.conf
   :language: bash


Pythonのweb frameworkのひとつ `Flask`_ に使用されているテンプレートエンジン `Jinja`_ が、
Fabricでも使えるようなのでuse_jinja=Trueして使うことにする。
{{ hoge }}で囲まれた部分が変数展開される。


::

  $ fab -l
  Available commands:

      server
      centos.cmd
      debian.upload
      freebsd.cmd
      gentoo.cmd


::

  $ fab server debian.upload:macaddress="01:23:45:67:89:ab",disk="vda",hostname="hoge.localnet",ipaddress="192.168.0.50",netmask="255.255.255.0",gateway="192.168.0.254",source_template="templates/debian_template.conf",dest_template="/var/diskless/scripts/debian_template.conf"

.. _Flask: http://flask.pocoo.org/
.. _Jinja: http://jinja.pocoo.org/

* http://docs.fabfile.org/en/1.8/api/contrib/files.html
* http://docs.fabfile.org/en/1.8/usage/fab.html#task-arguments
* https://speakerdeck.com/drillbits/fabric-python-developers-festa-2013-dot-03-number-pyfes
