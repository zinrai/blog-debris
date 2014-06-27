apt-cacher-ng でapt用のキャッシュプロキシを構築する
======================================================



.. author:: default
.. categories:: apt
.. tags:: debian, wheezy, apt
.. comments::

squidではなくapt-cacher-ngを使ってapt用のキャッシュプロキシを構築してみる。

::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.54-2

  $ cat /etc/debian_version
  7.5

server
------------------------

::

  $ apt-cache show apt-cacher-ng
  Package: apt-cacher-ng
  Version: 0.7.11-1
  Installed-Size: 1175
  Maintainer: Eduard Bloch <blade@debian.org>
  Architecture: amd64
  Depends: libbz2-1.0, libc6 (>= 2.10), libgcc1 (>= 1:4.1.1), liblzma5 (>= 5.1.1alpha+20120614), libstdc++6 (>= 4.6), libwrap0 (>= 7.6-4~), zlib1g (>= 1:1.1.4), debconf (>= 0.5) | debconf-2.0, adduser
  Pre-Depends: dpkg (>= 1.15.6)
  Recommends: perl (>> 5.8), ed
  Suggests: doc-base, libfuse2 (>= 2.5)
  Conflicts: logrotate (<< 3.8.0)
  Description-en: caching proxy server for software repositories
   Apt-Cacher NG is a caching proxy for downloading packages from Debian-style
   software repositories (or possibly from other types).
   .
   The main principle is that a central machine hosts the proxy for a local
   network, and clients configure their APT setup to download through it.
   Apt-Cacher NG keeps a copy of all useful data that passes through it, and when
   a similar request is made, the cached copy of the data is delivered without
   being re-downloaded.
   .
   Apt-Cacher NG has been designed from scratch as a replacement for
   apt-cacher, but with a focus on maximizing throughput with low system
   resource requirements. It can also be used as replacement for apt-proxy and
   approx with no need to modify clients' sources.list files.
  Homepage: http://www.unix-ag.uni-kl.de/~bloch/acng/
  Description-md5: b88e5e2d04c76e8d4500fb60880c7d76
  Tag: admin::package-management, implemented-in::c, interface::daemon,
   network::server, network::service, protocol::http, role::program,
   suite::debian, use::downloading, use::proxying,
   works-with::software:package, works-with::software:source
  Section: net
  Priority: optional
  Filename: pool/main/a/apt-cacher-ng/apt-cacher-ng_0.7.11-1_amd64.deb
  Size: 419640
  MD5sum: 85463208862ad21c4bbf7b7dc740bf4a
  SHA1: 3218bf36939cefedb87f286961719fc8128b9e5a
  SHA256: 5cb620e0c45509a68f3499a52c2810afac4893c851ffc34b4f31711cbe3c045c

::

  % apt-get install apt-cacher-ng

/etc/init.d/apt-cacher-ngを眺めてみると/etc/defautl/apt-cacher-ngファイルを読み込んでいて、
/etc/apt-cacher-ngディレクトリにある設定ファイルを読み込んでいた。

::

  $ ls /etc/apt-cacher-ng/
  acng.conf                backends_debvol          security.conf
  backends_debian          backends_ubuntu
  backends_debian.default  backends_ubuntu.default

::

  $ service apt-cacher-ng start

特になにも設定せずに起動すると3142でListenする。
(3142でListenするようにacng.confに書かれている。)
「 **http://${IP_ADDRESS}:3142/** 」にアクセスすると、キャッシュのヒット率などを確認できる。

client
------------------------

/etc/apt/apt.confか/etc/apt/apt.conf.dにプロキシの設定をする。

::

  % vi /etc/apt/apt.conf.d/02proxy
  Acquire::http::Proxy "http://192.168.0.10:3142";
  Acquire::ftp::Proxy "ftp://192.168.0.10:3142";

これでパッケージ配布サーバから同じパッケージを何度も取ってこなくてよくなり、
配布サーバに優しい環境ができた。

