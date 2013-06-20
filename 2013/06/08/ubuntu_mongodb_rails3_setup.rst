Rails3でMongoDBを使ってみる
======================================================



.. author:: default
.. categories:: ubuntu,mongodb,rails
.. tags:: ubuntu,mongodb,rails
.. comments::

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Ubuntu
  Description:    Ubuntu 12.04.2 LTS
  Release:        12.04
  Codename:       precise

  $ uname -a
  Linux ubuntu1204-64-base 3.2.0-45-generic #70-Ubuntu SMP Wed May 29 20:12:06 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  $ rails -v
  Rails 3.2.12

  $ rails new mongodb_app --skip-active-record

  $ cd mongodb_app

  $ vi Gemfile
  gem 'mongoid'
  gem 'bson_ext'

  $ bundle install --path vendor/bundle --binstubs

  $ bin/rails g mongoid:config
    create  config/mongoid.yml

  $ bin/rails g scaffold Post title:string subscription:text

  $ cat app/models/post.rb
  class Post
    include Mongoid::Document
    field :title, type: String
    field :subscription, type: String
  end

  $ mongo
  > show dbs
  mongodb_app_development 0.203125GB
  > use mongodb_app_development
  > show collections
  posts
  > db.posts.find()
  { "_id" : ObjectId("51b1ea5da64aef614e000001"), "title" : "sample", "subscription" : "text" }
  { "_id" : ObjectId("51b2afb0a64aef0c3f000001"), "title" : "hogehoge", "subscription" : "fugafuga" }


* http://mongoid.org/en/mongoid/
* http://docs.mongodb.org/ecosystem/tutorial/getting-started-with-ruby-on-rails-3/
