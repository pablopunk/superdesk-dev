#!/bin/bash

function open_if_mac {
  if [ "$(uname)" == "Darwin" ]; then
    open http://localhost:9000
  fi
}

function client {
  cd $HOME/src/superdesk-client-core && \
    npx grunt &

  open_if_mac
}

function fake-server {
  where="-master"
  if [ ! -z "$1" ]; then
    where="$1"
  fi

  open_if_mac

  cd $HOME/src/superdesk-client-core && \
    npx grunt --server=https://sd$where.test.superdesk.org/api --ws=wss://sd$where.test.superdesk.org/ws
}

function server {
  cd "$HOME/src/superdesk${1}/server" && \
    . $HOME/.pyvenv/bin/activate && \
    honcho start &
}

function start {
  server
  client
}

function stop {
  ps aux | grep [p]yvenv | tr -s ' ' | cut -d' ' -f2 | xargs kill -9
  ps aux | grep [w]s.py | tr -s ' ' | cut -d' ' -f2 | xargs kill -9
  killall grunt
}

function status {
  server=$(ps aux | grep [p]yvenv)
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
