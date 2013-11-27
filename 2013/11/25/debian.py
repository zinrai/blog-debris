from fabric.decorators import task
from fabric.contrib.files import upload_template

@task
def upload(macaddress, disk, hostname, ipaddress, netmask, gateway,
    source_template, dest_template):

    upload_template(
      source_template,
      dest_template,
      context={
        'macaddress': macaddress,
        'disk': disk,
        'hostname': hostname,
        'ipaddress': ipaddress,
        'netmask': netmask,
        'gateway': gateway,
      },
      use_jinja=True,
    )
