td-agent で外部プラグインを使ってみる
================================================



.. author:: default
.. categories:: td-agent
.. tags:: centos, td-agent, fluentd, s3, aws
.. comments::

* :doc:`../29/centos_65_td_agent_out_s3`

fluentdに組込まれているプラグインを標準プラグイン、それ以外を外部プラグイン呼ぶことにする。
今回は、いくつかの外部プラグインを使ってみる。

::

  $ uname -srv
  Linux 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

fluent-plugin-forest
----------------------------------------

標準プラグインだではタグごとにmatchを書かなければならないが、
これを使うと冗長な記述をテンプレートとしてまとめることができる。
tagというプレースホルダを使えるようになる。

::

  % /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-forest

fluent-plugin-config-expander
----------------------------------------

for文が書けたり、hostnameというプレースホルダを使用できる。

::

  % /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-config-expander

上記のプラグインを使った場合の設定はこんな感じ

::

  % vi /etc/td-agent/td-agent.conf
  <source>
    type config_expander
    <config>
      type tail
      path /var/log/secure
      pos_file /var/log/td-agent/secure.pos
      tag ${hostname}/syslog.secure
      format none
    </config>
  </source>

  <match *.**>
    type forest
    subtype s3

    <template>
      aws_key_id AWS_KEY_ID
      aws_sec_key AWS_SEC_KEY
      s3_bucket BUCKET_NAME
      s3_endpoint s3-ap-northeast-1.amazonaws.com
      path ${tag}/%Y/%m/%d/
      buffer_path /var/log/td-agent/s3

      time_slice_format %Y-%m-%d-%H-%M-%S
      time_slice_wait 5m
      utc

      buffer_chunk_limit 256m
    </template>
  </match>

* https://github.com/tagomoris/fluent-plugin-forest
* http://d.hatena.ne.jp/tagomoris/20120410/1334040981
* https://github.com/tagomoris/fluent-plugin-config-expander
* http://d.hatena.ne.jp/tagomoris/20120802/1343891922
