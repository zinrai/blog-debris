netcatを使わずに多段SSH
================================================



.. author:: default
.. categories:: ssh
.. tags:: ssh
.. comments::


netcatを使い多段SSHをしている記事をよく見掛けるが、
私はnetcatのプロセスが動くのが気持ち悪いのでこちらの方法で多段SSHをしている。
いつからあるオプションなのかは知らないがCentOS 6.4のSSH(OpenSSH 5.3)ではすでに存在している。

ssh(1)より。

::

  -W host:port
               Requests that standard input and output on the client be forwarded to host on
               port over the secure channel.  Implies -N, -T, ExitOnForwardFailure and
               ClearAllForwardings and works with Protocol version 2 only.

::

  $ vi $HOME/.ssh/config
  Host fumidai
    HostName 192.168.2.1
    User hoge
    Port 22
    IdentityFile ~/.ssh/id_rsa
  Host server1
    Hostname 192.168.0.2
    User fuga
    Port 22
    IdentityFile ~/.ssh/id_rsa
    ProxyCommand ssh fumidai -W %h:%p


::

  $ ssh server1
