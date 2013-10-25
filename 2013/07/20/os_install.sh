#!/bin/sh

get_conf() {
  if [ "$OS" = "FreeBSD" ]; then
    local MACADDR="`ifconfig | awk '/ether/ {print $NF}'`"
  elif [ "$OS" = "Linux" ]; then
    local MACADDR="`ifconfig | awk '/HWaddr/ {print $NF}'`"
  fi

  for a in $MACADDR; do
    grep -r $MACADDR ${CWD} | awk -F: '{print $1}'
  done
}

CWD=`dirname $0`

OS=`uname`
CONFFILE=`get_conf`

if [ -z "$CONFFILE" ]; then
  printf 'Script Not Found\n'
  exit 1
fi

if [ "$OS" = "FreeBSD" ]; then
  IFACE=`netstat -nr | awk '{if($3 ~ /^UG$/) print $6}'`
  MOUNTNAME=`sha256 -q $CONFFILE`
elif [ "$OS" = "Linux" ]; then
  IFACE=`netstat -nr | awk '{if($4 ~ /^UG$/) print $8}'`
  MOUNTNAME=`sha256sum $CONFFILE | awk '{print $1}'`
fi

mkdir /mnt/${MOUNTNAME}

$CONFFILE $IFACE $CWD $MOUNTNAME
