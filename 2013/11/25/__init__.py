from fabric.api import env
from fabric.decorators import task

from . import debian
from . import centos
from . import gentoo
from . import freebsd

@task
def server():
  env.hosts = ['192.168.0.1']
  env.port = 22
  env.user = 'root'
