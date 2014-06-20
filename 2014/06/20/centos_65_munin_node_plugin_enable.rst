Munin node のプラグイン有効化
==================================



.. author:: default
.. categories:: munin
.. tags:: centos, munin
.. comments::

* :doc:`../12/centos65_forward_proxy_squid`
* :doc:`../19/centos_65_munin_node_setup`

Forward Proxy Server(Squid)にmunin-nodeをインストールして監視下に置いた。
今回はSquid用のプラグインを有効にしてみる。
といってもコマンドを1回叩いてmunin-nodeを再起動するだけ。

::

  $ uname -srv
  Linux 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

::

  % munin-node-configure

プラグインが有効になっているか無効になっているかを調べられる。

::

  % munin-node-configure --suggest

プラグインが有効にできるかを教えてくれる。
(MySQLはインストールされていないからMySQLのプラグインは有効にできないよとか)

::

  % munin-node-configure --shell squid_
  ln -s '/usr/share/munin/plugins/squid_cache' '/etc/munin/plugins/squid_cache'
  ln -s '/usr/share/munin/plugins/squid_objectsize' '/etc/munin/plugins/squid_objectsize'
  ln -s '/usr/share/munin/plugins/squid_requests' '/etc/munin/plugins/squid_requests'
  ln -s '/usr/share/munin/plugins/squid_traffic' '/etc/munin/plugins/squid_traffic'

/usr/share/munin/pluginsにある各種プラグインを/etc/munin/pluginsに
シンボリックリンクしてmunin-nodeを再起動すればプラグインは有効になる。
--shellオプションを使うと/etc/munin/pluginsにシンボリックリンクするためのコマンドが標準出力される。
ここではsquidに関係するものだけ出力するように、squid_を指定している。
引数をなにも指定しなければ有効にできるプラグインが全て標準出力される。
あとはパイプしてshに流すだけ。

::

  % munin-node-configure --shell squid_ | sh

::

  % service munin-node restart

::

  $ munin-run squid_cache
  Maximum.value 4292608
  Current.value 951580

  $ munin-run squid_objectsize
  objectsize.value 179087.36

munin-runコマンドで有効にしたプラグインが値を取得できているか確認できる。

* http://munin-monitoring.org/wiki/FAQ_no_graphs
* http://munin-monitoring.org/wiki/munin-node-configure
* http://munin-monitoring.org/wiki/munin-run
