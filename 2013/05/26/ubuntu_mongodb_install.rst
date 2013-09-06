Ubuntu12.04にMongoDBをインストール
============================================



.. author:: default
.. categories:: mongodb
.. tags:: ubuntu,mongodb
.. comments::

積読になっていた「MongoDB イン・アクション」をようやく読み始めた。

「Ubuntu 12.04 amd64」にMongoDBをインストールして手を動かしてみたのでメモしておく。

Railsで使いたいなと思っているところ。

本家のドキュメントにaptでインストール出来ると書いているのでそれに従ってみた。

MongoDB インストール
----------------------------------------

::

  $ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  $ echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
  $ sudo apt-get update
  $ sudo apt-get install mongodb-10gen


::

  # apt-get install mongodb-10gen=2.2.3


で指定のVersionをインストールすることが出来る。


::

  # echo "mongodb-10gen hold" | dpkg --set-selections

でインストールしたVersionからアップグレードしないように出来る。

MongoDB 操作
----------------------------------------

::

  $ mongo
  MongoDB shell version: 2.4.3
  connecting to: test
  Welcome to the MongoDB shell.
  For interactive help, type "help".
  For more comprehensive documentation, see
          http://docs.mongodb.org/
  Questions? Try the support group
          http://groups.google.com/group/mongodb-user

  use tutorial

  db.users.insert({username: "hoge"})

  db.users.find()
  { "_id" : ObjectId("51a1f5c136f07a662784e8ae"), "username" : "hoge" }

  db.users.save({username: "moge"})

  db.users.find()
  { "_id" : ObjectId("51a1f5c136f07a662784e8ae"), "username" : "hoge" }
  { "_id" : ObjectId("51a1f8d336f07a662784e8af"), "username" : "moge" }

  db.users.count()
  2

  db.users.update({username: "hoge"}, {$set: {country: "canada"}})
  db.users.find({username: "hoge"})
  { "_id" : ObjectId("51a1f5c136f07a662784e8ae"), "country" : "canada", "username" : "hoge" }

  db.users.update({username: "hoge"}, {$unset: {country: 1}})
  db.users.find({username: "hoge"})
  { "_id" : ObjectId("51adf33a197bc318df1ad8ad"), "username" : "hoge" }


* http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
