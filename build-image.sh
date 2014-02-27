#! /bin/bash

KEYGEN=/usr/bin/ssh-keygen
KEYFILE=config/id_rsa

if [ ! -f $KEYFILE ]; then
  $KEYGEN -q -t rsa -N "" -f $KEYFILE
  cat $KEYFILE.pub >> config/authorized_keys
fi

echo "== Use this private key to log in =="
cat $KEYFILE

