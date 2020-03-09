#!/bin/bash

sudo ln -sf $PWD/superdesk-dev.sh /usr/local/bin/sd

./setup.sh && cd ./timetrack && npm install
