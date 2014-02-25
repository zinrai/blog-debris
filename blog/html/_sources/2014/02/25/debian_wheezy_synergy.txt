Synergyでマウスとキーボードを共有
===============================================================



.. author:: default
.. categories:: synergy
.. tags:: debian, wheezy, synergy
.. comments::

最近、デスクトップPCの横にノートPCを置いて作業をるすことが多くなったのでsynergyを入れてみた。

::

  $ lsb_release -a
  No LSB modules are available.
  Distributor ID: Debian
  Description:    Debian GNU/Linux 7.4 (wheezy)
  Release:        7.4
  Codename:       wheezy

  $ apt-cache show synergy
  Package: synergy
  Version: 1.3.8-2

  % apt-get install synergy

Server
------------------------------

::

  $ vi $HOME/.synergy.conf

  section: screens
    hoge:
    fuga:
  end

  section: links
    hoge:
      right = fuga
    fuga:
      left = hoge
  end

  section: aliases
    hoge:
      192.168.0.1
    fuga:
      192.168.0.2
  end

  section: options
    keystroke(alt+control+j) = switchToScreen(hoge)
    keystroke(alt+control+k) = switchToScreen(fuga)
  end

::

  $ synergys

Client
------------------------------

::

  $ synergyc 192.168.0.1

synergys(1),synergyc(1)をforegroundで起動したいときは、どちらも「-f」オプションを付ける。

* http://synergy-foss.org/?hl=ja
* http://synergy2.sourceforge.net/configuration.html
