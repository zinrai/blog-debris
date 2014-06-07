direnv + xbuildで環境構築
======================================================



.. author:: default
.. categories:: direnv, xbuild
.. tags:: debian, wheezy, direnv, xbuild
.. comments::

direnvを使うと、ディレクトリに環境変数を設定したファイルを置いておけば、
そのディレクトリがカレントになったときに設定した環境変数を有効することができる。
AWSのACCESS_KEYやSECRET_KEYなどの切り替えが捗りそう。
\*envでPATHを.zshrcなどに設定しなければいけないことに抵抗があったので、いい感じ。


::

  $ uname -a
  Linux zinrai 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2 x86_64 GNU/Linux

  $ cat /etc/debian_version
  7.5

xbuild
--------------------

Pythonを入れてみる。

::

  % apt-get install -y libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl

  $ git clone https://github.com/tagomoris/xbuild.git
  $ xbuild/python-install 2.7.6 $HOME/opt/python-2.7.6

direnv
--------------------

direnvのMakefileを眺めてみるとデフォルトは/usr/local/binにdirenvを配置するようになっている。
削除については特に書かれていない。dpkg(1),apt(8)管理外のソフトに勝手にこういう場所に配置して欲しくないので
`Stow <http://www.gnu.org/software/stow/>`_ を使うことにする。

::

  % apt-get install -y golang

  $ git clone https://github.com/zimbatm/direnv.git
  $ cd direnv
  $ make
  % make install DESTDIR=/usr/local/stow/direnv
  $ cd /usr/local/stow
  % stow -v direnv
  $ type direnv
  direnv is /usr/local/bin/direnv

zshの場合は.zshrcに以下の設定をしておく。

::

  $ vi $HOME/.zshrc
  type direnv > /dev/null
  if [ $? -eq 0 ]; then
    eval "$(direnv hook zsh)"
  fi

  $ source $HOME/.zshrc

インストールと設定は完了したので実際に使ってみる。
環境変数の設定は.envrcファイルに書く。

::

  $ mkdir -p lang/python-2.7.6
  $ cd lang/python-2.7.6

  $ vi .envrc
  PATH=$HOME/opt/python-2.7.6/bin:$PATH

  $ direnv allow .
  $  type python
  python is /home/zinrai/opt/python-2.7.6/bin/python

::

  $ wget https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.11.6.tar.gz
  $ tar zvxf virtualenv-1.11.6.tar.gz
  $ python virtualenv-1.11.6/virtualenv.py venv
  $ source venv/bin/activate
  $ type python
  python is /home/zinrai/lang/python2.7.6/venv/bin/python

試しに `Tinkerer <http://tinkerer.me/>`_ でも入れてみる。

::

  % apt-get install libxml2-dev libxslt-dev

  $ pip install tinkerer

* https://github.com/zimbatm/direnv
* https://github.com/tagomoris/xbuild
* https://pypi.python.org/pypi/virtualenv
* https://github.com/yyuu/pyenv/wiki/Common-build-problems
