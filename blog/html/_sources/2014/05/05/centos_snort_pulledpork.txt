snort ルールセット自動更新
==============================================



.. author:: default
.. categories:: snort
.. tags:: centos, snort, pulledpork, rpmbuild
.. comments::

* :doc:`../../05/04/centos_snort_install`

前回は自分でルールを書いていたが、既知の不正侵入や攻撃を検知するための
ルールがまとまったもの(ルールセット)がsnort.orgから配布されている。
ルールセットは大きく分けて2つある。

* | **Sourcefire VRT Certified Rules**
  | SroucefireのVulnerability Research Team(VRT)がメンテナンスをしているオフィシャルなルールセット。
  | 頻繁に更新が行われている。

  * | **Subscriber Release**
    | 最新のルールセット(有償)
  * | Registered User Release
    | 「Subscriber Release」より30日遅れのルールセット。snort.orgに登録すればダウンロードできる。

* | **Community Rules**
  | オープンソースコミュニティが作成したルールセットで、VRTが動作確認を行っている。

pulledporkを使うとルールセットのダウンロード、展開、指定のディレクトリに配置を自動でやってくれる。
今回は「Sourcefire VRT Certified Rules」の「Registered User Release」を使用する。

RPM作成
------------------------------

`OpenSUSE用のSRPM <http://rpm.pbone.net/index.php3/stat/4/idpl/24017916/dir/opensuse/com/pulledpork-0.6.1-6.6.noarch.rpm.html>`_
を見付けたのでダウンロードしてSPECファイルを参考にした。
rpm作成に使用したSPECファイルは `Gist <https://gist.github.com/zinrai/c5c29760b91aa438220c>`_ に置いた。

::

  $ rpmbuild -ba rpmbuild/SPECS/pulledpork.spec

pulledpork
------------------------------

::

  % diff -u pulledpork.conf.org pulledpork.conf

.. literalinclude:: pulledpork.conf.diff


::

  % pulledpork -c /etc/pulledpork/pulledpork.conf

      http://code.google.com/p/pulledpork/
        _____ ____
       `----,\    )
        `--==\\  /    PulledPork v0.7.0 - Swine Flu!
         `--==\\/
       .-~~~~-.Y|\\_  Copyright (C) 2009-2013 JJ Cummings
    @_/        /  66\_  cummingsj@gmail.com
      |    \   \   _(")
       \   /-| ||'--'  Rules give me wings!
        \_\  \_\\
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Checking latest MD5 for snortrules-snapshot-2961.tar.gz....
          No Match
          Done
  Rules tarball download of snortrules-snapshot-2961.tar.gz....
          They Match
          Done!
  Prepping rules from snortrules-snapshot-2961.tar.gz for work....
          Done!
  Reading rules...
  Setting Flowbit State....
          Enabled 35 flowbits
          Done
  Writing /etc/snort/rules/snort.rules....
          Done
  Generating sid-msg.map....
          Done
  Writing v1 /etc/snort/sid-msg.map....
          Done
  Writing /var/log/sid_changes.log....
          Done
  Rule Stats...
          New:-------21332
          Deleted:---0
          Enabled Rules:----5240
          Dropped Rules:----0
          Disabled Rules:---16091
          Total Rules:------21331
  No IP Blacklist Changes

  Done
  Please review /var/log/sid_changes.log for additional details
  Fly Piggy Fly!

* https://code.google.com/p/pulledpork/
* http://www.snort.org/snort-rules/
* https://www.snort.org/vrt/buy-a-subscription/
