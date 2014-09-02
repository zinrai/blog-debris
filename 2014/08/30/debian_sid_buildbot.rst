buildbot を動かしてみる
======================================



.. author:: default
.. categories:: buildbot
.. tags:: debian, sid, buildbot
.. comments::

CIフレームワークのひとつであるbuildbotを動かしてみる。
今回はチュートリアルに従いJOBを走らせるところまでやってみる。
http://buildbot.net/img/overview.png にあるようにbuildbotはmaster/slave構成で動作する。

::

  $ uname -srv
  Linux 3.14-2-amd64 #1 SMP Debian 3.14.15-2 (2014-08-09)

master
--------------------

::

  $ apt-cache show buildbot
  Package: buildbot
  Version: 0.8.9-1
  Installed-Size: 11483
  Maintainer: Andriy Senkovych <jolly_roger@itblog.org.ua>
  Architecture: all
  Depends:
  python (>= 2.7), python (<< 2.8), python-twisted,
  python-jinja2 (>= 2.1), python-sqlalchemy (>= 0.9~),
  python-sqlalchemy (<< 0.10), python-migrate (>= 0.6.1),
  python-dateutil (>= 1.5), libjs-sphinxdoc (>= 1.0),
  python-twisted-core (>= 2.0), python-twisted-web,
  python-twisted-words, dpkg (>= 1.15.4), adduser
  Recommends: buildbot-slave, python-twisted-mail, libaprutil1
  Suggests: bzr | subversion | cvs | mercurial | darcs | git
  Description-en: system to automate the compile/test cycle
  The BuildBot is a system to automate the compile/test cycle required
  by most software projects to validate code changes. By automatically
  rebuilding and testing the tree each time something has changed,
  build problems are pinpointed quickly, before other developers are
  inconvenienced by the failure. The guilty developer can be ng the builds on a variety of platforms, developers who do
  not have the facilities to test their changes everywhere before
  checkin will at least know shortly afterwards whether they have
  broken the build or not. Warning counts, lint checks, image size,
  compile time, and other build parameters can be tracked over time,
  are more visible, and are therefore easier to improve.
  Description-md5: 298ec22b779490a3c70577e0331e261a
  Homepage: http://buildbot.net
  Tag: devel::buildtools, devel::lang:python, devel::testing-qa,
  implemented-in::python, role::program
  Section: devel
  Priority: optional
  Filename: pool/main/b/buildbot/buildbot_0.8.9-1_all.deb
  Size: 1870110
  MD5sum: 5ff9f5f620abd35bff478c27cf51dbc8
  SHA1: 82ff1610db9445e130fc07fee52736b74d0472ff
  SHA256: f62a336ba3e1b517dcb714c1cdb1cd0d8e798760628f5c85a35a1b465bba9bd7

::

  % apt-get install buildbot

::

  % vi /etc/default/buildmaster
  MASTER_RUNNER=/usr/bin/buildbot

  # NOTE: MASTER_ENABLED has changed its behaviour in version 0.8.4. Use
  # 'true|yes|1' to enable instance and 'false|no|0' to disable. Other
  # values will be considered as syntax error.

  MASTER_ENABLED[1]=1 # 1-enabled, 0-disabled
  MASTER_NAME[1]="buildmaster #1" # short name printed on start/stop
  MASTER_USER[1]="buildbot" # user to run master as
  MASTER_BASEDIR[1]="/var/lib/buildbot/masters" # basedir to master (absolute path)
  MASTER_OPTIONS[1]="" # buildbot options
  MASTER_PREFIXCMD[1]="" # prefix command, i.e. nice, linux32, dchroot

::

  % cd /var/lib/buildbot/masters
  % buildbot create-master .
  % chown-R buildbot:buildbot .
  % cp master.cfg.sample master.cfg

::

  % service buildmaster start
  Starting buildmaster "buildmaster #1".

slave
--------------------

::

  $ apt-cache show buildbot-slave
  Package: buildbot-slave
  Version: 0.8.9-1
  Installed-Size: 653
  Maintainer: Andriy Senkovych <jolly_roger@itblog.org.ua>
  Architecture: all
  Depends:
  python (>= 2.7), python (<< 2.8), python-twisted,
  python-twisted-core (>= 2.2), python-twisted-words, adduser
  Suggests: buildbot, bzr | subversion | cvs | mercurial | darcs | git-core
  Breaks: buildbot (<< 0.8)
  Description-en: system to automate the compile/test cycle
  The BuildBot is a system to automate the compile/test cycle required
  by most software projects to validate code changes. By automatically
  rebuilding and testing the tree each time something has changed,
  build problems are pinpointed quickly, before other developers are
  inconvenienced by the failure. The guilty developer can be identified
  and harassed without human intervention.
  .
  By running the builds on a variety of platforms, developers who do
  not have the facilities to test their changes everywhere before
  checkin will at least know shortly afterwards whether they have
  broken the build or not. Warning counts, lint checks, image size,
  compile time, and other build parameters can be tracked over time,
  are more visible, and are therefore easier to improve.
  Description-md5: 298ec22b779490a3c70577e0331e261a
  Homepage: http://buildbot.net
  Tag: devel::buildtools, devel::testing-qa, implemented-in::python,
  role::program
  Section: devel
  Priority: optional
  Filename: pool/main/b/buildbot-slave/buildbot-slave_0.8.9-1_all.deb
  Size: 98744
  MD5sum: d709cebd7720976eaef401b68fbaea08
  SHA1: d31fd6a3dce03853db68c836552b2534cea75a0b
  SHA256: 9bf602c38f985491899b1f1a741beda966b185b8bdd8d56c9ba5a809592d10b1

::

  % apt-get install buildbot-slave

::

  % vi /etc/default/buildslave
  SLAVE_RUNNER=/usr/bin/buildslave

  # NOTE: SLAVE_ENABLED has changed its behaviour in version 0.8.4. Use
  # 'true|yes|1' to enable instance and 'false|no|0' to disable. Other
  # values will be considered as syntax error.

  SLAVE_ENABLED[1]=1 # 1-enabled, 0-disabled
  SLAVE_NAME[1]="buildslave #1" # short name printed on start/stop
  SLAVE_USER[1]="buildbot" # user to run slave as
  SLAVE_BASEDIR[1]="/var/lib/buildbot/slaves" # basedir to slave (absolute path)
  SLAVE_OPTIONS[1]="" # buildbot options
  SLAVE_PREFIXCMD[1]="" # prefix command, i.e. nice, linux32, dchroot

::

  % cd /var/lib/buildbot/slaves
  % buildslave create-slave . localhost:9989 example-slave pass
  % chown-R buildbot:buildbot .

::

  % service buildslave start
  Starting buildslave "buildslave #1".

これでmaster/slave構成の出来上がり。
あとは http://${ipaddress}:8010 にアクセスしてpyflakes/pyflakesでログイン
「Waterfall -> runtests -> Force Build」をクリックすればサンプルで登録されているJOBが走る。
JOBはmaster.cfgファイルを編集して追加していくことになる。
GitがないとエラーになるのでGitをインストールしておくこと。

::

  % apt-get install git

master.cfgは下記のようになっている。

::

  % cat master.cfg
  # -*- python -*-
  # ex: set syntax=python:

  # This is a sample buildmaster config file. It must be installed as
  # 'master.cfg' in your buildmaster's base directory.

  # This is the dictionary that the buildmaster pays attention to. We also use
  # a shorter alias to save typing.
  c = BuildmasterConfig = {}

  ####### BUILDSLAVES

  # The 'slaves' list defines the set of recognized buildslaves. Each element is
  # a BuildSlave object, specifying a unique slave name and password.  The same
  # slave name and password must be configured on the slave.
  from buildbot.buildslave import BuildSlave
  c['slaves'] = [BuildSlave("example-slave", "pass")]

  # 'protocols' contains information about protocols which master will use for
  # communicating with slaves.
  # You must define at least 'port' option that slaves could connect to your master
  # with this protocol.
  # 'port' must match the value configured into the buildslaves (with their
  # --master option)
  c['protocols'] = {'pb': {'port': 9989}}

  ####### CHANGESOURCES

  # the 'change_source' setting tells the buildmaster how it should find out
  # about source code changes.  Here we point to the buildbot clone of pyflakes.

  from buildbot.changes.gitpoller import GitPoller
  c['change_source'] = []
  c['change_source'].append(GitPoller(
          'git://github.com/buildbot/pyflakes.git',
          workdir='gitpoller-workdir', branch='master',
          pollinterval=300))

  ####### SCHEDULERS

  # Configure the Schedulers, which decide how to react to incoming changes.  In this
  # case, just kick off a 'runtests' build

  from buildbot.schedulers.basic import SingleBranchScheduler
  from buildbot.schedulers.forcesched import ForceScheduler
  from buildbot.changes import filter
  c['schedulers'] = []
  c['schedulers'].append(SingleBranchScheduler(
                              name="all",
                              change_filter=filter.ChangeFilter(branch='master'),
                              treeStableTimer=None,
                              builderNames=["runtests"]))
  c['schedulers'].append(ForceScheduler(
                              name="force",
                              builderNames=["runtests"]))

  ####### BUILDERS

  # The 'builders' list defines the Builders, which tell Buildbot how to perform a build:
  # what steps, and which slaves can execute them.  Note that any particular build will
  # only take place on one slave.

  from buildbot.process.factory import BuildFactory
  from buildbot.steps.source.git import Git
  from buildbot.steps.shell import ShellCommand

  factory = BuildFactory()
  # check out the source
  factory.addStep(Git(repourl='git://github.com/buildbot/pyflakes.git', mode='incremental'))
  # run the tests (note that this will require that 'trial' is installed)
  factory.addStep(ShellCommand(command=["trial", "pyflakes"]))

  from buildbot.config import BuilderConfig

  c['builders'] = []
  c['builders'].append(
      BuilderConfig(name="runtests",
        slavenames=["example-slave"],
        factory=factory))

  ####### STATUS TARGETS

  # 'status' is a list of Status Targets. The results of each build will be
  # pushed to these targets. buildbot/status/*.py has a variety to choose from,
  # including web pages, email senders, and IRC bots.

  c['status'] = []

  from buildbot.status import html
  from buildbot.status.web import authz, auth

  authz_cfg=authz.Authz(
      # change any of these to True to enable; see the manual for more
      # options
      auth=auth.BasicAuth([("pyflakes","pyflakes")]),
      gracefulShutdown = False,
      forceBuild = 'auth', # use this to test your slave once it is set up
      forceAllBuilds = False,
      pingBuilder = False,
      stopBuild = False,
      stopAllBuilds = False,
      cancelPendingBuild = False,
  )
  c['status'].append(html.WebStatus(http_port=8010, authz=authz_cfg))

  ####### PROJECT IDENTITY

  # the 'title' string will appear at the top of this buildbot
  # installation's html.WebStatus home page (linked to the
  # 'titleURL') and is embedded in the title of the waterfall HTML page.

  c['title'] = "Pyflakes"
  c['titleURL'] = "https://launchpad.net/pyflakes"

  # the 'buildbotURL' string should point to the location where the buildbot's
  # internal web server (usually the html.WebStatus page) is visible. This
  # typically uses the port number set in the Waterfall 'status' entry, but
  # with an externally-visible host name which the buildbot cannot figure out
  # without some help.

  c['buildbotURL'] = "http://localhost:8010/"

  ####### DB URL

  c['db'] = {
      # This specifies what database buildbot uses to store its state.  You can leave
      # this at its default for all but the largest installations.
      'db_url' : "sqlite:///state.sqlite",
  }

* http://buildbot.net/
* http://docs.buildbot.net/current/tutorial/
* http://docs.buildbot.net/current/tutorial/firstrun.html
