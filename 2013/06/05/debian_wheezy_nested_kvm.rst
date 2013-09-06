Debian wheezyでNested KVMを試してみる
================================================



.. author:: default
.. categories:: kvm
.. tags:: debian,kvm
.. comments::


`ganeti <https://code.google.com/p/ganeti/>`_ のbetaを触るのに実機を2,3台用意しないといけないことから開放されそう。

KVM インストール
--------------------

::

  # apt-get install install qemu-kvm libvirt-bin virtinst bridge-utils


Nested KVM
--------------------

Nested KVMを有効にするための設定を行う。

::

  # modinfo kvm_intel
  filename:       /lib/modules/3.2.0-4-amd64/kernel/arch/x86/kvm/kvm-intel.ko
  license:        GPL
  author:         Qumranet
  depends:        kvm
  intree:         Y
  vermagic:       3.2.0-4-amd64 SMP mod_unload modversions
  parm:           vpid:bool
  parm:           flexpriority:bool
  parm:           ept:bool
  parm:           unrestricted_guest:bool
  parm:           emulate_invalid_guest_state:bool
  parm:           vmm_exclusive:bool
  parm:           yield_on_hlt:bool
  parm:           fasteoi:bool
  parm:           nested:bool
  parm:           ple_gap:int
  parm:           ple_window:int

  # cat /sys/module/kvm_intel/parameters/nested
  N

  # vi /etc/modprobe.d/kvm-nested.conf
  options kvm_intel nested=1

  # modprobe -r kvm_intel
  # modprobe kvm_intel

  # cat /sys/module/kvm_intel/parameters/nested
  Y

仮想マシンの作成
----------------------------------------

.. code-block:: bash

  #!/bin/bash

  VM_NAME=$1
  MEM=$2
  SIZE=$3
  IFACE=$4
  OS=$5

  DISKIMAGE="/var/lib/libvirt/images/$VM_NAME"

  if [ "$OS" = "centos" ]; then
    # CentOS 6.4 amd64
    DIST='http://ftp.jaist.ac.jp/pub/Linux/CentOS/6.4/os/x86_64/'
  elif [ "$OS" = "precise" ]; then
    # Ubuntu 12.04 amd64
    DIST='http://ftp.riken.jp/Linux/ubuntu/dists/precise/main/installer-amd64/'
  elif [ "$OS" = "squeeze" ]; then
    # Debian Squeeze amd64
    DIST='http://ftp.jp.debian.org/debian/dists/squeeze/main/installer-amd64/'
  elif [ "$OS" = "wheezy" ]; then
    # Debian Wheezy amd64
    DIST='http://ftp.jp.debian.org/debian/dists/wheezy/main/installer-amd64/'
  fi

  virt-install --hvm --accelerate --nographics \
    --name $VM_NAME \
    --network bridge=$IFACE,model=virtio \
    --ram $MEM \
    --vcpus 1 \
    --cpu core2duo \
    --os-type linux \
    --location $DIST \
    --disk path=$DISKIMAGE.qcow2,format=qcow2,size=$SIZE,bus=virtio,cache=writethrough \
    --extra-args='console=tty0 console=ttyS0,115200n8'

::

  # vm-install.sh debian7_vm 1500 100 br1 wheezy


ゲストOSでの仮想マシン作成
----------------------------------------

ゲストOSでKVMのインストールと仮想マシンの作成を行う。

スクリプトは--cpuオプションを取っただけであとは同じ。

::

  # apt-get install install qemu-kvm libvirt-bin virtinst bridge-utils


.. code-block:: bash

  #!/bin/bash

  VM_NAME=$1
  MEM=$2
  SIZE=$3
  IFACE=$4
  OS=$5

  DISKIMAGE="/var/lib/libvirt/images/$VM_NAME"

  if [ "$OS" = "centos" ]; then
    # CentOS 6.4 amd64
    DIST='http://ftp.jaist.ac.jp/pub/Linux/CentOS/6.4/os/x86_64/'
  elif [ "$OS" = "precise" ]; then
    # Ubuntu 12.04 amd64
    DIST='http://ftp.riken.jp/Linux/ubuntu/dists/precise/main/installer-amd64/'
  elif [ "$OS" = "squeeze" ]; then
    # Debian Squeeze amd64
    DIST='http://ftp.jp.debian.org/debian/dists/squeeze/main/installer-amd64/'
  elif [ "$OS" = "wheezy" ]; then
    # Debian Wheezy amd64
    DIST='http://ftp.jp.debian.org/debian/dists/wheezy/main/installer-amd64/'
  fi

  virt-install --hvm --accelerate --nographics \
    --name $VM_NAME \
    --network bridge=$IFACE,model=virtio \
    --ram $MEM \
    --vcpus 1 \
    --os-type linux \
    --location $DIST \
    --disk path=$DISKIMAGE.qcow2,format=qcow2,size=$SIZE,bus=virtio,cache=writethrough \
    --extra-args='console=tty0 console=ttyS0,115200n8'

::

  # virsh net-list --all
  Name                 State      Autostart
  -----------------------------------------
  default              inactive   no

  # virsh net-start default
  # vm-install.sh debian7_nested 500 50 virbr0 wheezy

* http://www.debian.org/releases/wheezy/
* http://wiki.debian.org/KVM
* http://aikotobaha.blogspot.jp/2012/02/kvm-on-kvmnested-kvm.html
