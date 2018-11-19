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
  open_browser

  cd $client_core && \
    npx grunt
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
    npx grunt --server=https://$1.test.superdesk.org/api --ws=wss://$1.test.superdesk.org/ws
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
  # sometimes ws doesn't finish
  ps aux | grep ws.py | awk '{print $2}' | xargs kill -9
}

function server {
  if is_mac; then . $HOME/.pyvenv/bin/activate; fi

  cd "$superdesk/server" && \
    honcho start
}

function pr {
  echo "  $1"
  echo
}

function help {
  echo
  pr "- Show this help"
  pr "sd help"
  pr "- Start the client"
  pr "sd client"
  pr "- Start the server"
  pr "sd server"
  pr "- Start the client with a custom server (e.g sd-master)"
  pr "sd grunt <server-id>"
  pr "- Start the client with sd-master as server"
  pr "sd remote"
  pr "- Start the local server for tests"
  pr "sd test"
  pr "- Run e2e tests"
  pr "sd e2e"
  pr "- Run unit tests"
  pr "sd unit"
  pr "- Kill remaining ws processes"
  pr "sd kill"
}

# Execute
$@
