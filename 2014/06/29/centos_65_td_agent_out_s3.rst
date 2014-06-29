td-agent で S3 にログを送る
==================================================



.. author:: default
.. categories:: td-agent
.. tags:: centos, td-agent, s3, aws
.. comments::

td-agentを使って、/var/log/secureをS3に投げてみる。
今回は標準のプラグインのみを使用する。

::

  $ uname -srv
  Linux 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

本家のドキュメントだとインストールスクリプト(シェルスクリプト)をダウンロードして実行し、
問答無用でtd-agentをインストールするよう書かれている。
シェルスクリプトの中身は/etc/yum.repo.d/td.repoを配置して、
GPG Keyをインポートして、td-agentをインストールしているだけ。

::

  % vi /etc/yum.repo.d/td.repo
  [treasuredata]
  name=TreasureData
  baseurl=http://packages.treasuredata.com/redhat/$basearch
  enabled=0
  gpgcheck=1
  gpgkey=http://packages.treasuredata.com/GPG-KEY-td-agent

::

  % rpm --import http://packages.treasuredata.com/GPG-KEY-td-agent

::

  $ yum info --enablerepo=treasuredata td-agent
  Available Packages
  Name        : td-agent
  Arch        : x86_64
  Version     : 1.1.20
  Release     : 0
  Size        : 64 M
  Repo        : treasuredata
  Summary     : td-agent
  URL         : http://treasure-data.com/
  License     : APL2
  Description :

::

  % yum install --enablerepo=treasuredata td-agent

::

  % vi /etc/td-agent/td-agent.conf
  <source>
    type tail
    path /var/log/secure
    pos_file /var/log/td-agent/secure.pos
    tag syslog.secure
    format none
  </source>

  <match *.*>
    type s3

    aws_key_id ${AWS_KEY_ID}
    aws_sec_key ${AWS_SEC_KEY}
    s3_bucket ${BUCKET_NAME}
    s3_endpoint s3-ap-northeast-1.amazonaws.com
    path %Y/%m/%d/secure_
    buffer_path /var/log/td-agent/s3

    time_slice_format %Y%m%d%H
    time_slice_wait 5m
    utc

    buffer_chunk_limit 256m
  </match>

/var/log/secureのPermissionは600でそのままだとtd-agentが読み込めずに
ログ(/var/log/td-agent/td-agent.log)に「Permission denied」とか吐くので、
secureログのPermissionを644にする。

::

  % chmod 644 /var/log/secure

::

  % service td-agent start

td-agent.confを書き換え設定を反映させたければreloadする。

::

  % service td-agent reload

* http://docs.fluentd.org/ja/articles/install-by-rpm
* http://toolbelt.treasuredata.com/sh/install-redhat.sh
* http://docs.fluentd.org/ja/articles/in_tail
* http://docs.fluentd.org/ja/articles/out_s3
* http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region
