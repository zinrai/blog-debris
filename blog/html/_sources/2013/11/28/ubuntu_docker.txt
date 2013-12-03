Dockerを使ってみる
=======================================



.. author:: default
.. categories:: docker
.. tags:: ubuntu, docker
.. comments::

`dotcloud`_ がオープンソースで公開している `Docker`_ というソフトウェアを知った。
Linuxコンテナの実装の一つである `LXC`_ を使いOSレベルの仮想化を行い、
`Aufs`_ で「 :doc:`../../09/10/debian_wheezy_chroot_aufs` 」
のようにルートファイルとの差分を保持し、その差分をGitっぽく管理できる
フロントエンドだということが使ってみてわかった。

::

  $ uname -a
  Linux asuna 3.8.0-33-generic #48~precise1-Ubuntu SMP Thu Oct 24 16:28:06 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Ubuntu
  Description:    Ubuntu 12.04.3 LTS
  Release:        12.04
  Codename:       precise

Docker インストール
------------------------------

::

  $ sudo apt-get update
  $ sudo apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring
  $ sudo reboot

  $ sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
  $ sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
  $ sudo apt-get update
  $ sudo apt-get install lxc-docker

::

  $ apt-cache search lxc-docker
  lxc-docker - Linux container runtime
  lxc-docker-0.5.3 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.0 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.1 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.2 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.3 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.4 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.5 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.6 - lxc-docker is a Linux container runtime
  lxc-docker-0.6.7 - Linux container runtime
  lxc-docker-0.7.0 - Linux container runtime

::

  $ apt-cache show lxc-docker
  Package: lxc-docker
  Version: 0.7.0
  License: unknown
  Vendor:
  Architecture: amd64
  Maintainer: docker@dotcloud.com
  Installed-Size: 0
  Depends: lxc-docker-0.7.0
  Homepage: http://www.docker.io/
  Priority: extra
  Section: default
  Filename: pool/main/l/lxc-docker/lxc-docker_0.7.0_amd64.deb
  Size: 1914
  SHA256: c344f7f4a583b6bda2dcb1adab10b92580c260ed058b762c083230f7868c9ead
  SHA1: 157a3335594693062b85887f0a0b34e8afe79f69
  MD5sum: 96821dcce0250cc522dbee2e36263bc5
  Description: Linux container runtime
   Docker complements LXC with a high-level API which operates at the process
   level. It runs unix processes with strong guarantees of isolation and
   repeatability across servers.
   Docker is a great building block for automating distributed systems:
   large-scale web deployments, database clusters, continuous deployment systems,
   private PaaS, service-oriented architectures, etc.

Docker 使い方
------------------------------

* commitしなければコンテナの変更はコンテナ停止後に破棄される。

::

  % docker -v
  Docker version 0.7.0, build 0d078b6

  % docker pull ubuntu
  Pulling repository ubuntu
  8dbd9e392a96: Download complete
  b750fe79269d: Download complete
  27cf78414709: Download complete

  % docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  ubuntu              12.04               8dbd9e392a96        7 months ago        128 MB (virtual 128 MB)
  ubuntu              latest              8dbd9e392a96        7 months ago        128 MB (virtual 128 MB)
  ubuntu              precise             8dbd9e392a96        7 months ago        128 MB (virtual 128 MB)
  ubuntu              12.10               b750fe79269d        8 months ago        175.3 MB (virtual 350.6 MB)
  ubuntu              quantal             b750fe79269d        8 months ago        175.3 MB (virtual 350.6 MB)

  % docker run -i -t -d --name ubuntu01 ubuntu:12.04 /bin/bash
  % docker run -i -t -d --name ubuntu02 ubuntu:12.04 /bin/bash
  % docker run -i -t -d --name ubuntu03 ubuntu:12.04 /bin/bash
  % docker run -i -t -d -p 80 --name ubuntu04 ubuntu:12.04 /bin/bash
  % docker run -i -t -d -p 80 -p 22 --name ubuntu05 ubuntu:12.04 /bin/bash

  % docker ps
  CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                                          NAMES
  1734fac49073        ubuntu:12.04        /bin/bash           51 seconds ago      Up 51 seconds       0.0.0.0:49159->22/tcp, 0.0.0.0:49160->80/tcp   ubuntu05
  e54ec245fe2a        ubuntu:12.04        /bin/bash           2 minutes ago       Up 2 minutes        0.0.0.0:49158->80/tcp                          ubuntu04
  fe54b9318dba        ubuntu:12.04        /bin/bash           8 hours ago         Up 8 hours                                                         ubuntu03
  46d0ef544132        ubuntu:12.04        /bin/bash           8 hours ago         Up 8 hours                                                         ubuntu02
  8fcfa5265233        ubuntu:12.04        /bin/bash           8 hours ago         Up 8 hours                                                         ubuntu01

  % docker attach ubuntu01
  「Ctrl-p Ctrl-q」でデタッチ

  % docker stop ubuntu01

  % docker commit ubuntu02 hoge/ubuntu02
  % docker run -i -t -d --name ubuntu06 hoge/ubuntu02 /bin/bash
  % docker stop ubuntu06
  % docker rm ubuntu06
  % docker rmi hoge/ubuntu02

  % docker export ubuntu02 > ubuntu02.tar
  % docker import http://exsample.com/ubuntu02.tar ubuntu02
  % cat ubuntu02.tar | docker import - ubuntu02:new

.. _LXC: http://linuxcontainers.org/
.. _Aufs: http://aufs.sourceforge.net/
.. _dotcloud: https://www.dotcloud.com/
.. _Docker: http://docs.docker.io/

* https://index.docker.io/
* http://docs.docker.io/en/latest/commandline/cli/
* http://docs.docker.io/en/latest/installation/ubuntulinux/#ubuntu-precise
* http://www.infoq.com/jp/articles/docker-containers
