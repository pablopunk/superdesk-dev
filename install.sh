#!/bin/bash

if [[ ! "$(whoami)" == "root" ]]
then
  echo "Rerun this script as sudo"
  exit 1
fi

ln -sf $PWD/superdesk-dev.sh /usr/local/bin/sd
