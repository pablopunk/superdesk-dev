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

function grunt {
  npx grunt --server=https://$1.test.superdesk.org/api --ws=wss://$1.test.superdesk.org/ws
}

function kill {
  ps aux | grep ws.py | awk '{print $2}' | xargs kill -9
  killall gunicorn
}

function wipe {
  mongo --eval "db.dropDatabase();" superdesk
}

function deps {
  cd $HOME/src/superdesk-core && git fetch upstream && git reset --hard upstream/master && pip3 install -r requirements.txt --user
  cd $HOME/src/superdesk-client-core && rm -rf node_modules yarn.lock && yarn && yarn link
  if [ ! -z "$1" ]; then
    ls -d $HOME/src/superdesk$1/server || ( echo "$1 doesn't appear to be a project" && exit 1 )
    pip3 install -r $HOME/src/superdesk$1/server/requirements.txt
    cd $HOME/src/superdesk$1/client && rm -rf node_modules yarn.lock && yarn && yarn link superdesk-core
  else
    cd $HOME/src/superdesk/server && pip3 install -r requirements.txt
    cd $HOME/src/superdesk/client && rm -rf node_modules yarn.lock && yarn && yarn link superdesk-core
  fi
}

function populate {
  ls -d $HOME/src/superdesk$1/server && \
    python3 $HOME/src/superdesk$1/server/manage.py app:initialize_data && \
    python3 $HOME/src/superdesk$1/server/manage.py app:prepopulate && \
    python3 $HOME/src/superdesk$1/server/manage.py app:index_from_mongo --all
}

function pr {
  echo "  $1"
  echo
}

function timetrack {
  $HOME/src/superdesk-dev/timetrack/index.js $@
}

function help {
  echo
  pr "- Show this help"
  pr "sd help"
  pr "- Start the client with a custom server (e.g sd-master)"
  pr "sd grunt <server-id>"
  pr "- Kill remaining server processes"
  pr "sd kill"
  pr "Install dependencies for a project (e.g -planning)"
  pr "sd deps <-project>"
  pr "- Drop superdesk database"
  pr "sd wipe"
  pr "- Initialize data and populate for a specific project (e.g -belga)"
  pr "sd populate <-project>"
  pr "- Show your commits from all projects (use 'last' argument for last month period)"
  pr "sd timetrack <last>"
}

# Execute
$@
