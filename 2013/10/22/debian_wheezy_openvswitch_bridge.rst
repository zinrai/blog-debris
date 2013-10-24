Open vSwitchを使ってみる
================================================================



.. author:: default
.. categories:: openvswitch
.. tags:: openvswitch, debian
.. comments::


bridgeをOpen vSwitchに変えてみた。

::

  % lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.2 (wheezy)
  Release:        7.2
  Codename:       wheezy

bridge停止
------------------------------

::

  % service networking stop

  % brctl delif br0 eth0
  % brctl delif br1 eth1
  % brctl delbr br0
  % brctl delbr br1

  % modprobe -r bridge


Open vSwitch インストール
------------------------------

::

  % apt-get install -y openvswitch-switch openvswitch-datapath-source openvswitch-brcompat module-assistant
  % module-assistant auto-install openvswitch-datapath-source
  % modprobe openvswitch_mod
  % modprobe brcompat_mod
  % service openvswitch-switch start

::

  % vi /etc/default/openvswitch-switch
  BRCOMPAT=yes

::

  % vi /etc/modules
  openvswitch_mod
  brcompat_mod


Open vSwitch bridge設定
------------------------------

::

  % ovs-vsctl add-br br0
  % ovs-vsctl add-br br1
  % ovs-vsctl add-port br0 eth0
  % ovs-vsctl add-port br1 eth1

::

  % ovs-vsctl show
  2a8eb1c3-4273-42b3-9f84-108918d53d15
      Bridge "br0"
          Port "eth0"
              Interface "eth0"
          Port "br0"
              Interface "br0"
                  type: internal
      Bridge "br1"
          Port "eth1"
              Interface "eth1"
          Port "br1"
              Interface "br1"
                  type: internal
      ovs_version: "1.4.2"

::

  % vi /etc/network/interfaces
  auto eth0
  iface eth0 inet manual
    up /sbin/ifconfig eth0 up
    down /sbin/ifconfig eth0 down

  auto eth1
  iface eth1 inet manual
    up /sbin/ifconfig eth1 up
    down /sbin/ifconfig eth1 down

libvirt
------------------------------

openvswitch-brcompat使わず仮想マシンをOpen vSwitchのbridgeに接続するには、
<virtualport type='openvswitch'>を追加する。

::

 % libvirtd --version
 libvirtd (libvirt) 0.9.12

::

  % virsh edit vm01
  <interface type='bridge'>
        <source bridge='br1'/>
        <virtualport type='openvswitch'>
        <model type='virtio'/>
  </interface>

* http://libvirt.org/formatnetwork.html
