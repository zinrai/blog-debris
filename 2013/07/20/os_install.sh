#!/bin/sh

CWD=`dirname $0`

get_conf() {
  if [ "$OS" = "FreeBSD" ]; then
    local MACADDR="`ifconfig | awk '/ether/ {print $NF}'`"
  elif [ "$OS" = "Linux" ]; then
    local MACADDR="`ifconfig | awk '/HWaddr/ {print $NF}'`"
  fi

  for a in $MACADDR; do
    grep -r $MACADDR ${CWD}/*.conf | awk -F: '{print $1}'
  done
}

OS=`uname`
CONFFILE=`get_conf`

if [ "$OS" = "FreeBSD" ]; then
  IFACE=`netstat -nr | awk '{if($3 ~ /^UG$/) print $6}'`
  MOUNTNAME=`sha256 -q $CONFFILE`
elif [ "$OS" = "Linux" ]; then
  IFACE=`netstat -nr | awk '{if($4 ~ /^UG$/) print $8}'`
  MOUNTNAME=`sha256sum $CONFFILE | awk '{print $1}'`
fi

mkdir /mnt/${MOUNTNAME}

if [ -n "$CONFFILE" ]; then
  $CONFFILE $IFACE $CWD $MOUNTNAME
fi
