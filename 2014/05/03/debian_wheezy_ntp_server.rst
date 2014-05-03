NTPサーバ 構築
================================================



.. author:: default
.. categories:: ntp
.. tags:: debian, wheezy, ntp
.. comments::

stratum1のNTPサーバを探してNTPサーバを構築してみた。

* `SHOSHIN <http://www.shoshin.co.jp/c/endrun/cdma.html>`_

  * ntp.shoshin.co.jp

* `日本標準時プロジェクト <http://www2.nict.go.jp/aeri/sts/tsp/PubNtp/>`_

  * ntp.nict.jp

* `アマノ ビジネスソリューションズ株式会社 <http://www.e-timing.ne.jp/>`_

  * ats1.e-timing.ne.jp

::

  $ cat /etc/debian_version
  7.5

  $ uname -a
  Linux hoge 3.2.0-4-amd64 #1 SMP Debian 3.2.54-2 x86_64 GNU/Linux

::

  % apt-cache show ntp
  Package: ntp
  Version: 1:4.2.6.p5+dfsg-2
  Installed-Size: 1238
  Maintainer: Debian NTP Team <pkg-ntp-maintainers@lists.alioth.debian.org>
  Architecture: amd64
  Depends: adduser, lsb-base (>= 3.2-13), netbase, libc6 (>= 2.12), libcap2 (>= 2.10), libedit2 (>= 2.11-20080614-1), libopts25 (>= 1:5.12), libssl1.0.0 (>= 1.0.0)
  Pre-Depends: dpkg (>= 1.15.7.2)
  Recommends: perl
  Suggests: ntp-doc
  Breaks: dhcp3-client (<< 4.1.0-1)
  Description-en: Network Time Protocol daemon and utility programs
   NTP, the Network Time Protocol, is used to keep computer clocks
   accurate by synchronizing them over the Internet or a local network,
   or by following an accurate hardware receiver that interprets GPS,
   DCF-77, NIST or similar time signals.
   .
   This package contains the NTP daemon and utility programs.  An NTP
   daemon needs to be running on each host that is to have its clock
   accuracy controlled by NTP.  The same NTP daemon is also used to
   provide NTP service to other hosts.
   .
   For more information about the NTP protocol and NTP server
   configuration and operation, install the package "ntp-doc".
  Homepage: http://support.ntp.org/
  Description-md5: 220487bd9eceed70fec6b929cb922fd3
  Tag: admin::benchmarking, admin::configuring, implemented-in::c,
   interface::commandline, interface::daemon, network::server,
   network::service, protocol::TODO, role::program, scope::utility,
   use::monitor, use::timekeeping
  Section: net
  Priority: optional
  Filename: pool/main/n/ntp/ntp_4.2.6.p5+dfsg-2_amd64.deb
  Size: 561700
  MD5sum: 508a6082b9aa647949a4f6aab81f51c4
  SHA1: f41ab7b089503b2d4a4a67f289b5d8222f0e8912
  SHA256: bd2d31f80e7dd070228664f8b48496505395ead795e4ef190cf7bff9931af332


::

  % apt-get install ntp

ntp.nict.jpがIPv6のほうを見に行ってしまっていたのでntp.conf(5),ntpd(8)を眺めてみてIPv4を見に行くように設定した。

::

  $ diff -u /etc/ntp.conf.org /etc/ntp.conf
  --- /etc/ntp.conf.org   2014-05-04 06:58:03.118951714 +0900
  +++ /etc/ntp.conf       2014-05-04 06:59:49.198747483 +0900
  @@ -18,10 +18,13 @@
   # pool.ntp.org maps to about 1000 low-stratum NTP servers.  Your server will
   # pick a different set every time it starts up.  Please consider joining the
   # pool: <http://www.pool.ntp.org/join.html>
  -server 0.debian.pool.ntp.org iburst
  -server 1.debian.pool.ntp.org iburst
  -server 2.debian.pool.ntp.org iburst
  -server 3.debian.pool.ntp.org iburst
  +#server 0.debian.pool.ntp.org iburst
  +#server 1.debian.pool.ntp.org iburst
  +#server 2.debian.pool.ntp.org iburst
  +#server 3.debian.pool.ntp.org iburst
  +server -4 ntp.nict.jp
  +server -4 ats1.e-timing.ne.jp
  +server -4 ntp.shoshin.co.jp

   # Access control configuration; see /usr/share/doc/ntp-doc/html/accopt.html for
   # details.  The web page <http://support.ntp.org/bin/view/Support/AccessRestrictions>
  @@ -42,6 +45,7 @@
   # Clients from this (example!) subnet have unlimited access, but only if
   # cryptographically authenticated.
   #restrict 192.168.123.0 mask 255.255.255.0 notrust
  +restrict 192.168.0.0 mask 255.255.255.0


   # If you want to provide time to your local subnet, change the next line.

::

  % service ntp restart

::

  $ ntpq -pn
       remote           refid      st t when poll reach   delay   offset  jitter
  ==============================================================================
   133.243.238.243 .NICT.           1 u   22   64    1   10.702   -3.196   0.000
   61.114.187.55   .PPS.            1 u   21   64    1   10.119   -2.076   0.000
   210.168.211.231 .CDMA.           1 u   20   64    1   12.140   -0.344   0.000

* http://ja.wikipedia.org/wiki/Network_Time_Protocol
* http://support.ntp.org/bin/view/Main/WebHome
* http://www.eecis.udel.edu/~mills/ntp/html/comdex.html
