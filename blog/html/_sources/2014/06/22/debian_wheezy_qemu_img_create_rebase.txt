qemu-img の使い方
==============================



.. author:: default
.. categories:: qemu
.. tags:: debian, wheezy, qemu
.. comments::

KVMを使うときにqemu-img(8)でよく使うサブコマンドをメモしておく。

::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2

  $ cat /etc/debian_version
  7.5

ディスクイメージ作成
----------------------------------

「GuestOSのディスク容量が足りない!!」とならないようにディスクイメージは多めに設定するようにしている。

::

  % qemu-img create -f qcow2 debian_wheezy.qcow2 200G

差分ディスクイメージ作成
----------------------------------

snapshotではなく差分をディスクイメージとして書き出すようにしている。
差分ディスクイメージをGuestOSのディスクイメージに指定すればベースイメージの状態にいつでも戻すことができる。

::

  % qemu-img create -b debian_wheezy.qcow2 -f qcow2 debian_wheezy.diff.qcow2

rebase
----------------------------------

差分ディスクイメージをinfoすると、どのディスクイメージから作成された
差分ディスクイメージなのかを示すbacking fileという項目が追加される。
rebaseはbacking fileを変更することができる。

::

  % qemu-img info debian_wheezy.qcow2
  image: debian_wheezy.qcow2
  file format: qcow2
  virtual size: 200G (214748364800 bytes)
  disk size: 1.4G
  cluster_size: 65536

::

  % qemu-img info debian_wheezy.diff.qcow2
  image: debian_wheezy.diff.qcow2
  file format: qcow2
  virtual size: 200G (214748364800 bytes)
  disk size: 13G
  cluster_size: 65536
  backing file: debian_wheezy.qcow2

::

  % cp debian_wheezy.qcow2 debian_wheezy.rebase.qcow2
  % qemu-img rebase -b debian_wheezy.rebase.qcow2 debian_wheezy.diff.qcow2

commit
----------------------------------

commitを使うと差分ディスクイメージをbacking fileへマージすることがきる。
backing fileに指定されているディスクイメージをコピーして、コピーしたディスクイメージをrebaseしてcommitすれば
元のbacking fileを汚すことなく差分のマージされたディスクイメージを作ることができたりする。

::

  $ qemu-img info debian_wheezy.diff.qcow2
  image: debian_wheezy.diff.qcow2
  file format: qcow2
  virtual size: 200G (214748364800 bytes)
  disk size: 1.0G
  cluster_size: 65536
  backing file: debian_wheezy.rebase.qcow2

::

  qemu-img commit -f qcow2 debian_wheezy.diff.qcow2

思っていたより書き起こすのに時間が掛かってしまった。info時の情報がおかしいのは途中でディスクイメージを作り直したため。
