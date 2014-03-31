rbenv + ruby-build
============================================================



.. author:: default
.. categories:: rbenv, ruby-build
.. tags:: debian, wheezy, rbenv, ruby-build
.. comments::

最近使い始めてglobal,local,shellの理解がぼんやりしていたのでメモ

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

  % apt-get install libreadline6-dev zlib1g-dev libssl-dev build-essential

::

  $ git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv
  $ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

  $ vi $HOME/.bashrc
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"

  $ . .bashrc

rbenv
------------------------------

サブコマンドがいろいろあるけれど、自分はこれだけ覚えていればいいかなと思っている。

::

  $ rbenv
  rbenv 0.4.0-89-g14bc162


install
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ rbenv install 1.9.3-p392
  $ rbenv install 2.0.0-p353

uninstall
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ rbenv uninstall 1.9.3-p392
  $ rbenv uninstall 2.0.0-p353


rehash
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

rbenvを使うとPATHに~/.rbenv/shimsが追加される。
gemでインストールした実行ファイルは~/.rbenv/versions/x.y.x/binに格納される。
rehashを実行するとgemでインストールした実行ファイルを呼び出すための実行ファイルが~/.rbenv/shimsに生成される。
自分はbundlerを使っているので、bundler自体をインストールしたときにしか使っていない。

::

  $ gem install bundler
  $ rbenv rehash

rubyのversionの切り替えには以下の3つが使われている。ここがrbenvの肝だと思う。


.. csv-table::
  :widths: 50,150

  ~/.rbenv/version, デフォルトで使用するversionが書かれている。
  .ruby-version, カレントディレクトリにこのファイルがある場合はここに書かれているversionが優先される。
  RBENV_VERSION, この環境変数がセットされている場合はここに書かれているversionが優先される。

**RBENV_VERSION > .ruby-version > ~/.rbenv/version** となっている。

global
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

  $ rbenv global 1.9.3-p392

local
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

カレントディレクトリに.ruby-versionが生成される。--unsetオプションでカレントディレクトリの.ruby-versionは削除される。

::

  $ rbenv local 1.9.3-p392
  $ rbenv local --unset

shell
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

RBENV_VERSIONがセットされる。--unsetオプションでRBENV_VERSIONはunsetされる。

::

  $ rbenv shell 1.9.3-p392
  $ rbenv shell --unset


* https://github.com/sstephenson/rbenv
* https://github.com/sstephenson/ruby-build
