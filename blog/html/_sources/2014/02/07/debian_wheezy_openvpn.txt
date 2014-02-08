OpenVPN サーバ構築
===============================================================



.. author:: default
.. categories:: openvpn
.. tags:: debian, wheezy, openvpn
.. comments::

::

  $ uname -a
  Linux hoge 3.2.0-4-amd64 #1 SMP Debian 3.2.51-1 x86_64 GNU/Linux

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.3 (wheezy)
  Release:        7.3
  Codename:       wheezy

::

  % sysctl -p
  net.ipv4.ip_forward = 1

サーバ
-------------------------

ルーティングモードとブリッジモードがあり、今回はブリッジモードで動かす。

::

  % apt-get install openvpn openssl bridge-utils

  % openvpn --version
  OpenVPN 2.2.1 x86_64-linux-gnu [SSL] [LZO2] [EPOLL] [PKCS11] [eurephia] [MH] [PF_INET6] [IPv6 payload 20110424-2 (2.2RC2)] built on Jun 18 2013
  Originally developed by James Yonan
  Copyright (C) 2002-2010 OpenVPN Technologies, Inc. <sales@openvpn.net>

::

  % cp -r /usr/share/doc/openvpn/examples/easy-rsa /etc/openvpn
  % cd /etc/openvpn/easy-rsa/2.0
  % . ./vars
  % ./build-ca
  % ./build-key-server server <- サーバ用の証明書
  % ./build-dh

  % ./build-key client01 <- クライアント用の証明書

  % cd keys
  % cp ca.crt server.crt server.key dh1024.pem /etc/openvpn

::

  % vi /etc/openvpn/openvpn.conf
  port 1194
  proto tcp
  dev tap0
  ca ca.crt
  cert server.crt
  key server.key
  dh dh1024.pem
  server-bridge 192.168.2.1 255.255.255.0 192.168.2.250 192.168.2.253
  push "route 192.168.2.0 255.255.255.0"
  duplicate-cn
  keepalive 10 120
  comp-lzo
  persist-key
  persist-tun
  status openvpn-status.log
  verb 4

::

  % vi /etc/network/interfaces
  auto lo
  iface lo inet loopback

  auto br0
  iface br0 inet static
  address 192.168.2.1
  netmask 255.255.255.0
  gateway 192.168.2.254
  bridge_ports eth0
  up openvpn --mktun --dev tap0
  up ifconfig tap0 up
  up brctl addif br0 tap0
  down brctl delif br0 tap0
  down ifconfig tap0 down
  down openvpn --rmtun --dev tap0

::

  % update-rc.d openvpn defaults



クライアント
-------------------------

サーバ側で生成したクライアント用の証明書をクライアントPCにもってくる。

::

  % apt-get install openvpn openssl

  % vi /etc/openvpn/client.conf
  client
  dev tap
  proto tcp
  remote 10.0.0.1 1194
  resolv-retry infinite
  nobind
  persist-key
  persist-tun
  ca ca.crt
  cert client01.crt
  key client01.key
  ns-cert-type server
  comp-lzo
  verb 3

* http://www.openvpn.jp/document/how-to/#RoutedOrBridged
* http://www.openvpn.jp/document/how-to/#CertificateAuthority
