#!/bin/bash

sudo ln -sf $PWD/superdesk-dev.sh /usr/local/bin/sd

if [[ `uname` == "Linux" ]]; then
  sudo ./setup.sh
else
  ./setup.sh
fi

cd ./timetrack && yarn
