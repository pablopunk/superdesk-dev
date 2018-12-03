#!/bin/bash

# *nix
[[ "$(uname)" = "Linux" ]] && linux=1 || mac=1

function is_mac {
  [ "$mac" = "1"  ]
}

function is_linux {
  [ "$linux" = "1"  ]
}

function open_browser {
  cmd=open
  is_linux && cmd=xdg-open
  [ -z "$DISPLAY" ] && cmd=echo
  $cmd http://localhost:9000
}

function client {
  open_browser
  npx grunt
}

function remote {
  open_browser
  grunt sd-master
}

function grunt {
  npx grunt --server=https://$1.test.superdesk.org/api --ws=wss://$1.test.superdesk.org/ws
}

function e2e {
  npm run protractor
}

function unit {
  npm test
}

function test {
  npm run start-test-server
}

function kill {
  ps aux | grep ws.py | awk '{print $2}' | xargs kill -9
  killall gunicorn
}

function server {
  is_mac && . $HOME/.pyvenv/bin/activate
  honcho start
}

function vps {
  npx grunt --ws=wss://sd.pablovarela.ga/ws --server=https://sd.pablovarela.ga/api
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
  pr "- Start the client with localhost as a server but with SSL"
  pr "sd vps"
  pr "- Start the client with sd-master as server"
  pr "sd remote"
  pr "- Start the local server for tests"
  pr "sd test"
  pr "- Run e2e tests"
  pr "sd e2e"
  pr "- Run unit tests"
  pr "sd unit"
  pr "- Kill remaining server processes"
  pr "sd kill"
}

# Execute
$@
