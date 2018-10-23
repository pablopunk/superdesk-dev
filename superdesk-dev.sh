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

function fake-server {
  where="-master"
  if [ ! -z "$1" ]; then
    where="$1"
  fi

  open_browser

  cd $client_core && \
    npx grunt --server=https://sd$where.test.superdesk.org/api --ws=wss://sd$where.test.superdesk.org/ws
}

function test-server {
  open_browser

  cd $client_core && \
    npm run start-test-server
}

function server {
  if is_mac; then . $HOME/.pyvenv/bin/activate; fi

  cd "$superdesk${1}/server" && \
    honcho start &
}

function start {
  server
  client
}

function stop {
  if is_mac; then
    ps aux | grep [p]yvenv | tr -s ' ' | cut -d' ' -f2 | xargs kill -9
    ps aux | grep [w]s.py | tr -s ' ' | cut -d' ' -f2 | xargs kill -9
  fi

  ps aux | grep wsgi | tr -s ' ' | cut -d' ' -f2 | xargs kill -9
  sudo killall honcho
  killall grunt
}

function status {
  server=$(ps aux | grep [p]yvenv)
  if is_linux; then server=$(ps aux | grep honcho); fi
  ( [ ! -z "$server" ] && echo "Server up" ) || echo "Server down"

  client=$(ps aux | grep [g]runt)
  ( [ ! -z "$client" ] && echo "Client up" ) || echo "Client down"
}

function restart {
  stop
  start $1
}

# Execute the function $1 with the argument $2
$1 $2
