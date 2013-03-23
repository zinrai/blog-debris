Tinkerer + Github
========================================



.. author:: default
.. categories:: python,github
.. tags:: python,github
.. comments::



jekyll + Githubを使ってブログを書いていたのだけれど
ローカルで確認するのにWEBRick動かすということに
面倒くささを感じ流らく放置してしまっていた。

もっと手軽な(Sphinxみたいにhtmlが掃き出される)
ものはないかと探してみたところTinkererというものを見付けた。

::

  $ pip install tinkerer


::

  $ tinker -s


::

  $ wget http://dl.dropbox.com/u/218108/files/japanesesupport.py
  $ mkdir _exts
  $ mv japanesesupport.py _exts
  $ hg clone https://bitbucket.org/vladris/tinkerer-contrib
  $ cp `find tinkerer-contrib -name withgithub.py` _exts
  $ rm -rf tinkerer-contrib
  $ touch .nojekyll


conf.py 修正
--------------------
::

  extensions = ['tinkerer.ext.blog', 'tinkerer.ext.disqus', 'japanesesupport', 'withgithub']

  # Add templates to be rendered in sidebar here
  html_sidebars = {
      "**": ["recent.html", "categories.html", "tags.html", "searchbox.html"]
  }


::

  $ tinker -p 'first post'
  $ tinker -b
  $ git init
  $ git add .
  $ git commit -m 'first post'
  $ git remote add origin git@github.com:zinrai/zinrai.github.com.git
  $ git push -u origin master


* http://www.tinkerer.me/exts/withgithub.html
* http://sphinx-users.jp/reverse-dict/html/japanese.html
