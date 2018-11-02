#!/bin/bash

client_core="$HOME/src/superdesk-client-core"
superdesk="$HOME/src/superdesk"

# *nix
if [ "$(uname)" = "Linux"  ]
then
  linux=1
else
  mac=1
fi

function is_mac {
  [ "$mac" = "1"  ]
}

function is_linux {
  [ "$linux" = "1"  ]
}

function open_browser {
  cmd="open"
  if is_linux; then cmd="xdg-open"; fi
  $cmd http://localhost:9000
}

function client {
  cd $client_core && \
    npx grunt &

  open_browser
}

function remote {
  where="sd-master"
  if [ ! -z "$1" ]; then
    where="$1"
  fi

  open_browser

  cd $client_core && \
    grunt $where
}

function grunt {
  cd $client_core && \
    npx grunt --server=https://$2.test.superdesk.org/api --ws=wss://$2.test.superdesk.org/ws
}

function e2e {
  cd $client_core && \
    npm run protractor
}

function unit {
  cd $client_core && \
    npm test
}

function test {
  cd $client_core && \
    npm run start-test-server
}

function kill {
  ps aux | grep ws.py | cut -d ' ' -f2 | xargs kill -9
}

function server {
  if is_mac; then . $HOME/.pyvenv/bin/activate; fi

  cd "$superdesk/server" && \
    honcho start
}

# Execute
$@
