#!/bin/bash

function client {
  cd $HOME/src/superdesk-client-core && \
    npx grunt &

  echo $! > /tmp/superdesk-client-pid

  open http://localhost:9000
}

function server {
  cd "$HOME/src/superdesk${1}/server" && \
    . $HOME/.pyvenv/bin/activate && \
    honcho start &

  echo $! > /tmp/superdesk-server-pid
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
