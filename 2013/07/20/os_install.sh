#!/bin/sh

get_conf() {
  if [ "$OS" = "FreeBSD" ]; then
    local MACADDR="`ifconfig | awk '/ether/ {print $NF}'`"
  elif [ "$OS" = "Linux" ]; then
    local MACADDR="`ifconfig | awk '/HWaddr/ {print $NF}'`"
  fi

  for a in $MACADDR; do
    find . -name ${a}.conf
  done
}

OS=`uname`
CONFFILE=`get_conf`

if [ "$OS" = "FreeBSD" ]; then
  IFACE=`netstat -nr | awk '{if($3 ~ /^UG$/) print $6}'`
  DIRNAME=`sha256 -q $CONFFILE`
elif [ "$OS" = "Linux" ]; then
  IFACE=`netstat -nr | awk '{if($4 ~ /^UG$/) print $8}'`
  DIRNAME=`sha256sum $CONFFILE | awk '{print $1}'`
fi

mkdir /mnt/${DIRNAME}

if [ -n "$CONFFILE" ]; then
  ./$CONFFILE $IFACE $DIRNAME
fi
