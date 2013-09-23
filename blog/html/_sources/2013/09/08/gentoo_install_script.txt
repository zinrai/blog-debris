Gentoo Linux インストールスクリプト
===============================================================



.. author:: default
.. categories:: gentoo
.. tags:: gentoo
.. comments::


* 「そして私はOpenOfficeのビルドを諦めた」
* 「俺たちはなにと戦っているのだ...」

などの名言で知られる(私調べ)
Gentoo Linuxのインストールスクリプトを書いてみた。

* 「Gentoo LiveCD」を使わなくてもGentooはインストール出来るよ
* Gentooインストールまでの各種コマンドを間違いなく打ち込む自身がないよ
* Gentoo怖くないよ

などが今回のモチベーションである。

「 :doc:`../07/debian_wheezy_pxeboot` 」で構築した環境にスクリプトを配置する。

その他に、 `stage3`_ , `portage`_ , カーネルのコンフィグファイルをスクリプトのあるディレクトリに用意しておく。

実機,仮想環境(KVM)ともに動作することは確認した。
Gentooを複数台セットアップする予定はいまのところない。

::

  % cp /boot/config-* /var/scripts
  % cd /var/scripts
  % wget http://ftp.jaist.ac.jp/pub/Linux/Gentoo/snapshots/portage-20130830.tar.bz2
  % wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3/stage3-amd64-20130822.tar.bz2


::

  # vi /var/scripts/gentoo_install.conf

.. literalinclude:: gentoo_install.conf
   :language: bash




.. _stage3: http://www.gentoo.org/main/en/where.xml
.. _portage: http://ftp.jaist.ac.jp/pub/Linux/Gentoo/snapshots/

* http://d.hatena.ne.jp/meech/20120221/1329839829
* http://www.gentoo.org/doc/ja/handbook/handbook-amd64.xml?full=1

