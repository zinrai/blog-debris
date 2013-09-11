cowbuilderを使ったsandbox環境
==============================================================



.. author:: default
.. categories:: cowbuilder
.. tags:: debian, wheezy, chroot, cowbuilder
.. comments::


今回もchrootネタである。
cowbuilderを使うとホスト環境を汚さずにいろいろできる。

* 気になるパッケージをとりあえずインストールして使ってみたい
* Debianのパッケージが古く最新のソースをビルドして使ってみる
* Texを使いたいがホスト環境には入れたくない

などのシーンで私は使っている。

::

  lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.1 (wheezy)
  Release:        7.1
  Codename:       wheezy

::

  % apt-get install cowbuilder


::

  % cowbuilder --create --distribution wheezy --architecture amd64 --basepath  /var/cache/pbuilder/base_wheezy_amd64.cow

ベース環境を毎回取ってくるのはサーバに負荷がかかるので同じバージョンとアーキテクチャを使うときはコピーする。

::

  % cd /var/cache/pbuilder
  % cp -R base_wheezy_amd64.cow rails3_wheezy_amd64.cow

.. csv-table::
   :widths: 15, 70

    --distribution,作成するディストリビューションの指定。sidもしくはコードネームを選ぶ。(省略した場合のデフォルトはsid)
    --architecture,アーキテクチャの指定。(省略した場合のデフォルトはホストと同じ)
    --basepath,テンプレートのディレクトリパス(省略した場合のデフォルトは/var/cache/pbuilder/base.cow)


「--save」オプションを付けると変更を保存できる。
オプションなしの場合はログアウトすると変更は消える。


::

  % cowbuilder --login --save --basepath /var/cache/pbuilder/base_wheezy_amd64.cow


「--bindmount」オプションでホストのディレクトリをchroot環境にマウントできる。

::

  % cowbuilder --login --save --bindmount /home/hoge/dir --basepath /var/cache/pbuilder/base_wheezy_amd64.cow

ほかにもいろいろオプションがあるのでcowbuilder(8)を眺めてみるといい。
