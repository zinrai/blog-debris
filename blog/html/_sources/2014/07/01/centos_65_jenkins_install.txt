CentOS 6.5 に Jenkins インストール
==================================================



.. author:: default
.. categories:: jenkins
.. tags:: centos, yum, jenkins
.. comments::



::

  $ uname -srv
  Linux 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013

  $ cat /etc/redhat-release
  CentOS release 6.5 (Final)

::

  % wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
  % rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

::

  % yum install java-1.7.0-openjdk
  % yum install jenkins

::

  % service jenkins start

起動スクリプトの/etc/init.d/jenkinsを眺めてみたら、/etc/sysconfig/jenkinsにJenkinsの設定が書かれていた。

* http://pkg.jenkins-ci.org/redhat/
