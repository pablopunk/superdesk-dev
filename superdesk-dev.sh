#!/bin/bash

function client {
  cd $HOME/src/superdesk-client-core && \
    npx grunt &

  open http://localhost:9000
}

function fake-server {
  cd $HOME/src/superdesk-client-core && \
    npx grunt --server=https://sd-master.test.superdesk.org/api --ws=wss://sd-master.test.superdesk.org/ws &

  open http://localhost:9000
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
