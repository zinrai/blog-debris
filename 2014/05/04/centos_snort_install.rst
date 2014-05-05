CentOS 6.5 snort インストール
========================================



.. author:: default
.. categories:: snort
.. tags:: centos, snort, rpmbuild
.. comments::

使う用事ができたのでインストールして簡単なルールを書いて動作確認してみる。

::

  $ uname -a
  Linux localhost.localdomain 2.6.32-431.11.2.el6.x86_64 #1 SMP Tue Mar 25 19:59:55 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux

  $ cat /etc/centos-release
  CentOS release 6.5 (Final)

::

  $ yum info snort
  Name        : snort
  Arch        : x86_64
  Epoch       : 1
  Version     : 2.9.6.1
  Release     : 1
  Size        : 15 M
  Repo        : installed
  Summary     : An open source Network Intrusion Detection System (NIDS)
  URL         : http://www.snort.org/
  License     : GPL
  Description : Snort is an open source network intrusion detection system, capable of
              : performing real-time traffic analysis and packet logging on IP networks.
              : It can perform protocol analysis, content searching/matching and can be
              : used to detect a variety of attacks and probes, such as buffer overflows,
              : stealth port scans, CGI attacks, SMB probes, OS fingerprinting attempts,
              : and much more.
              :
              : Snort has three primary uses. It can be used as a straight packet sniffer
              : like tcpdump(1), a packet logger (useful for network traffic debugging,
              : etc), or as a full blown network intrusion detection system.
              :
              : You MUST edit /etc/snort/snort.conf to configure snort before it will work!
              :
              : There are 5 different packages available. All of them require the base
              : snort rpm (this one). Additionally, you may need to chose a different
              : binary to install if you want database support.
              :
              : If you install a different binary package /usr/sbin/snort should end up
              : being a symlink to a binary in one of the following configurations:
              :
              :         plain                Snort (this package, required)
              :
              : Please see the documentation in /usr/share/doc/snort-2.9.6.1 for more
              : information on snort features and configuration.

::

  $ yum info daq
  Name        : daq
  Arch        : x86_64
  Version     : 2.0.2
  Release     : 1
  Size        : 961 k
  Repo        : installed
  Summary     : Data Acquisition Library
  URL         : http://www.snort.org/
  License     : GNU General Public License
  Description : Data Acquisition library for Snort.

::

  Name        : libdnet
  Arch        : x86_64
  Version     : 1.12
  Release     : 6.el6
  Size        : 65 k
  Repo        : installed
  From repo   : epel
  Summary     : Simple portable interface to lowlevel networking routines
  URL         : http://code.google.com/p/libdnet/
  License     : BSD
  Description : libdnet provides a simplified, portable interface to several
              : low-level networking routines, including network address
              : manipulation, kernel arp(4) cache and route(4) table lookup and
              : manipulation, network firewalling (IP filter, ipfw, ipchains,
              : pf, ...), network interface lookup and manipulation, raw IP
              : packet and Ethernet frame, and data transmission.


rpmbuild
--------------------

snort本家のCentOS用のRPMがうまくインストールできなかったので、snort本家が配布しているSRPMをrebuildした。

::

  % yum install rpm-build rpmdevtools
  $ rpmdev-setuptree

::

  $ curl -o snort-2.9.6.1-1.src.rpm -O -L http://www.snort.org/downloads/2909
  $ curl -o daq-2.0.2-1.src.rpm -O -L http://www.snort.org/downloads/2900

daq
^^^^^^^^^^^^^^^^^^^^

::

  % yum install flex bison
  $ rpmbuild --rebuild daq-2.0.2-1.src.rpm
  % rpm -ivh rpmbuild/RPMS/x86_64/daq-2.0.2-1.x86_64.rpm

snort
^^^^^^^^^^^^^^^^^^^^

::

  % rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
  % yum-config-manager --disable epel

  % yum --enablerepo=epel install libdnet-devel
  % yum install autoconf automake pcre-devel libpcap-devel gcc openssl-devel

  $ rpmbuild --rebuild snort-2.9.6.1-1.src.rpm
  % rpm -ivh rpmbuild/RPMS/x86_64/snort-2.9.6.1-1.x86_64.rpm


snort 設定
--------------------

::

  $ diff -u snort.conf.org snort.conf

.. literalinclude:: snort.conf.diff

::

  $ vi /etc/snort/rules/icmp.rules
  alert icmp any any -> any any

::

  % service snortd start

pingを送受信したときにアラートを掃くルールを書いて、
/var/log/snort/alertにアラートが吐かれることを確認した。

* http://www.snort.org/
* http://www.snort.org/doc
* http://manual.snort.org/
* http://manual.snort.org/node23.html
* http://manual.snort.org/node176.html
