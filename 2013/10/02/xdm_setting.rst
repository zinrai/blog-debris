XDM 設定
======================



.. author:: default
.. categories:: xdm
.. tags:: debian, xdm
.. comments::

XDMのログイン画面はデフォルトだと寂しいので、
ログイン毎に背景画像が代わるようにしている。

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.1 (wheezy)
  Release:        7.1
  Codename:       wheezy


::

  % cd /etc/X11/xdm
  % cp xdm-config xdm-config.bak
  % cp Xsetup Xsetup_0
  % cp Xresources Xresources_0

xdm-config
------------------------------

::

  % diff -u xdm-config xdm-config.bak
  --- xdm-config  2013-10-03 00:28:33.000000000 +0900
  +++ xdm-config.bak      2013-10-02 23:18:35.000000000 +0900
  @@ -15,7 +15,7 @@
   DisplayManager.keyFile:                /etc/X11/xdm/xdm-keys
   DisplayManager.servers:                /etc/X11/xdm/Xservers
   DisplayManager.accessFile:     /etc/X11/xdm/Xaccess
  -DisplayManager*resources:      /etc/X11/xdm/Xresources_0
  +DisplayManager*resources:      /etc/X11/xdm/Xresources
   DisplayManager.willing:                su nobody -s /bin/sh -c /etc/X11/xdm/Xwilling
   ! All displays should use authorization, but we cannot be sure
   ! X terminals will be configured to support it, so those that do not will
  @@ -25,7 +25,7 @@
   DisplayManager*chooser:                /usr/lib/X11/xdm/chooser
   DisplayManager*startup:                /etc/X11/xdm/Xstartup
   DisplayManager*session:                /etc/X11/xdm/Xsession
  -DisplayManager*setup:          /etc/X11/xdm/Xsetup_0
  +DisplayManager*setup:          /etc/X11/xdm/Xsetup
   DisplayManager*reset:          /etc/X11/xdm/Xreset
   DisplayManager*authComplain:   true

Xsetup_0
------------------------------

このファイルに指定したディレクトリにある画像を
ランダムに背景画像にするスクリプトを書く。

指定した範囲の値から一つ取り出す処理にathena-jot(1)、
背景画像の設定にはxsetbg(1x)を使った。

::

  % apt-get install athena-jot xloadimage


::

  % vi /etc/X11/xdm/Xsetup_0

::

  #!/bin/sh
  #
  # This script is run as root before showing login widget.

  #xsetroot -solid rgb:8/8/8

  IMGDIR=/home/hoge/gazo

  IMG_COUNT=`ls $IMGDIR | wc -l`
  LINE_NUM=`jot -r 1 1 $IMG_COUNT`

  IMG=`ls $IMGDIR | awk 'NR == '$LINE_NUM' { print $1 }'`

  if [ -x /usr/bin/xsetbg ]; then
    /usr/bin/xsetbg -fullscreen $IMGDIR/$IMG
  fi

Xresources_0
------------------------------

::

  % vi /etc/X11/xdm/Xresources_0

::

  --- Xresources	2011-10-23 01:48:34.000000000 +0900
  +++ Xresources_0	2013-10-03 01:50:27.000000000 +0900
  @@ -15,34 +15,35 @@
    Ctrl<Key>Return: set-session-argument(failsafe) finish-field()\n\
    <Key>Return: set-session-argument() finish-field()

  -xlogin*greeting: Welcome to CLIENTHOST
  -xlogin*namePrompt: \040\040\040\040\040\040\040Login:
  +xlogin*greeting: Hello World
  +xlogin*namePrompt: Login:
   xlogin*fail: Login incorrect or forbidden by policy

   #if WIDTH > 800
  -xlogin*greetFont: -adobe-helvetica-bold-o-normal--24-240-75-75-p-138-iso8859-1
  -xlogin*font: -adobe-helvetica-medium-r-normal--18-180-75-75-p-98-iso8859-1
  -xlogin*promptFont: -adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-1
  -xlogin*failFont: -adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-1
  -xlogin*greetFace:	Serif-24:bold:italic
  -xlogin*face: 		Helvetica-18
  -xlogin*promptFace: 	Helvetica-18:bold
  -xlogin*failFace: 	Helvetica-18:bold
  +xlogin*greetFont: -adobe-helvetica-bold-o-normal--10-100-75-75-p-60-iso8859-1
  +xlogin*font: -adobe-helvetica-medium-r-normal--10-100-75-75-p-56-iso8859-1
  +xlogin*promptFont: -adobe-helvetica-bold-r-normal--10-100-75-75-p-60-iso8859-1
  +xlogin*failFont: -adobe-helvetica-bold-o-normal--10-100-75-75-p-60-iso8859-1
  +xlogin*greetFace:       Serif-8:bold:italic
  +xlogin*face:            Helvetica-8
  +xlogin*promptFace:      Helvetica-8:bold
  +xlogin*failFace:        Helvetica-8:bold
   #else
  -xlogin*greetFont: -adobe-helvetica-bold-o-normal--17-120-100-100-p-92-iso8859-1
  -xlogin*font: -adobe-helvetica-medium-r-normal--12-120-75-75-p-67-iso8859-1
  -xlogin*promptFont: -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1
  -xlogin*failFont: -adobe-helvetica-bold-o-normal--14-140-75-75-p-82-iso8859-1
  -xlogin*greetFace:	Serif-18:bold:italic
  -xlogin*face:		Helvetica-12
  -xlogin*promptFace:	Helvetica-12:bold
  -xlogin*failFace:	Helvetica-14:bold
  +xlogin*greetFont: -adobe-helvetica-bold-o-normal--10-100-75-75-p-60-iso8859-1
  +xlogin*font: -adobe-helvetica-medium-r-normal--10-100-75-75-p-56-iso8859-1
  +xlogin*promptFont: -adobe-helvetica-bold-r-normal--10-100-75-75-p-60-iso8859-1
  +xlogin*failFont: -adobe-helvetica-bold-o-normal--10-100-75-75-p-60-iso8859-1
  +xlogin*greetFace:       Serif-8:bold:italic
  +xlogin*face:            Helvetica-8
  +xlogin*promptFace:      Helvetica-8:bold
  +xlogin*failFace:        Helvetica-8:bold
   #endif

   #ifdef COLOR
  -xlogin*borderWidth: 1
  -xlogin*frameWidth: 5
  -xlogin*innerFramesWidth: 2
  +xlogin*geometry: 180x120-0-0
  +!xlogin*borderWidth: 1
  +!xlogin*frameWidth: 5
  +!xlogin*innerFramesWidth: 2
   xlogin*shdColor: grey30
   xlogin*hiColor: grey90
   xlogin*background: grey
  @@ -59,13 +60,13 @@
   xlogin*hiColor: black
   #endif

  -#if PLANES >= 8
  -xlogin*logoFileName: /usr/share/X11/xdm/pixmaps/debian.xpm
  -#else
  -xlogin*logoFileName: /usr/share/X11/xdm/pixmaps/debianbw.xpm
  -#endif
  -xlogin*useShape: true
  -xlogin*logoPadding: 10
  +!#if PLANES >= 8
  +!xlogin*logoFileName: /usr/share/X11/xdm/pixmaps/debian.xpm
  +!#else
  +!xlogin*logoFileName: /usr/share/X11/xdm/pixmaps/debianbw.xpm
  +!#endif
  +!xlogin*useShape: true
  +!xlogin*logoPadding: 10


   XConsole.text.geometry:	480x130
