Debian wheezy で wpasupplicant を使う
======================================================



.. author:: default
.. categories:: wpasupplicant
.. tags:: debian, wpasupplicant
.. comments::

たまにやる無線LANの設定に時間を割かれないようにメモしておく。
自分はwicdやnetwork-managerよりもこちらのほうがしっくりきている。

::

  $ uname -srv
  Linux 3.2.0-4-amd64 #1 SMP Debian 3.2.57-3+deb7u2

  $ cat /etc/debian_version
  7.5

::

  $ apt-cache show wpasupplicant
  Package: wpasupplicant
  Source: wpa (1.0-3)
  Version: 1.0-3+b2
  Installed-Size: 1364
  Maintainer: Debian/Ubuntu wpasupplicant Maintainers <pkg-wpa-devel@lists.alioth.debian.org>
  Architecture: amd64
  Depends: libc6 (>= 2.4), libdbus-1-3 (>= 1.1.4), libncurses5 (>= 5.5-5~), libnl-3-200 (>= 3.2.7), libnl-genl-3-200 (>= 3.2.7), libpcsclite1 (>= 1.0.0), libreadline5 (>= 5.2), libssl1.0.0 (>= 1.0.0), libtinfo5, lsb-base (>= 3.0-6), adduser, initscripts (>= 2.88dsf-13.3)
  Suggests: wpagui, libengine-pkcs11-openssl
  Description-en: client support for WPA and WPA2 (IEEE 802.11i)
   WPA and WPA2 are methods for securing wireless networks, the former
   using IEEE 802.1X, and the latter using IEEE 802.11i. This software
   provides key negotiation with the WPA Authenticator, and controls
   association with IEEE 802.11i networks.
  Multi-Arch: foreign
  Homepage: http://w1.fi/wpa_supplicant/
  Description-md5: db096b22f8ec5f5c7a8ec614d12ca20a
  Tag: admin::configuring, implemented-in::c, network::client,
   network::configuration, protocol::ssl, role::program,
   security::cryptography, uitoolkit::ncurses, use::configuring
  Section: net
  Priority: optional
  Filename: pool/main/w/wpa/wpasupplicant_1.0-3+b2_amd64.deb
  Size: 607788
  MD5sum: 9bfeaab049b5ec37a790edd0c9135394
  SHA1: 5283d6c97f994a028338e4c86922fb664ee53051
  SHA256: d64c9958245cef38bef65acad696b34066177dfe319b29876106e1738f9b10d6

::

  % apt-get install wireless-tools wpasupplicant

interfaces(5)にパスワード直書きすることもできるけど気持ち悪いのでwpa_passphrase(8)を使っている。
wpa_passphrase(8)をコマンドラインで実行すると履歴に残ってしまうのでシェルスクリプトにしている。

::

  $ vi wpa_conf.sh
  #！/bin/bash
  wpa_passphrase hogehoge fugafuga

::

  $ ./wpa_conf.sh
  network={
          ssid="hogehoge"
          #psk="fugafuga"
          psk=b276f31c7d3c1862c991617334abe708b16c1dcc85c1f1cf5ceae1c15bb75572
  }

wpa_passphrase(8)を実行すると上記のような設定が標準出力される。
あとはこれをコピーしてinterfaces(5)から読み込む設定をするだけ。

::

  $ vi /etc/wpa_supplicant/hoge.conf

  network={
          scan_ssid=1 <- アクセスポイントがステルスの場合は必須
          ssid="hogehoge"
          psk=b276f31c7d3c1862c991617334abe708b16c1dcc85c1f1cf5ceae1c15bb75572
  }

scan_ssidなどの説明は/usr/share/doc/wpasupplicant/README.Debian.gzに書いてある。

::

  % vi /etc/network/interfaces
  iface hogehoge inet dhcp
  wpa-conf /etc/wpa_supplicant/hogehoge.conf

::

  ifup wlan0=hogehoge
  ifdown wlan0

interface(5)に設定を書いて、ifup(8),ifdown(8)をたたくだけなのでとても楽だ。
