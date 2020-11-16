#!/bin/bash

# *nix
[[ "$(uname)" = "Linux" ]] && linux=1 || mac=1

function is_mac {
  [ "$mac" = "1"  ]
}

function is_linux {
  [ "$linux" = "1"  ]
}

function grunt {
  npx grunt --server=https://$1.test.superdesk.org/api --ws=wss://$1.test.superdesk.org/ws
}

function wipe {
  mongo --eval "db.dropDatabase();" superdesk
}

function deps {
  sudo echo
  cd $HOME/src/superdesk-core && git fetch upstream &&\
    git reset --hard upstream/develop &&\
    python3 -m venv ./env &&\
    . ./env/bin/activate &&\
    pip install -r dev-requirements.txt
  cd $HOME/src/superdesk-client-core && rm -rf node_modules yarn.lock package-lock.json && npm i && npm link
  if [ ! -z "$1" ]; then
    ls -d $HOME/src/superdesk$1/server || ( echo "$1 doesn't appear to be a project" && exit 1 )
    cd $HOME/src/superdesk$1/server &&\
      python3 -m venv ./env &&\
      . ./env/bin/activate &&\
      pip install -r requirements.txt
    cd $HOME/src/superdesk$1/client && rm -rf node_modules yarn.lock package-lock.json && npm i && npm link superdesk-core
  else
    cd $HOME/src/superdesk/server &&\
      python3 -m venv ./env &&\
      . ./env/bin/activate &&\
      pip install -r requirements.txt
    cd $HOME/src/superdesk/client && rm -rf node_modules yarn.lock package-lock.json && npm i && npm link superdesk-core
  fi
}

function user {
  if [ ! -d $HOME/src/superdesk$1/server ]; then
    echo "Server '$1' not found in $HOME/src/superdesk$1/server"
    exit 1
  fi

  python3 $HOME/src/superdesk$1/server/manage.py users:create -u pablovarela -p Pablo1234 -e 'pablo@pablopunk.com' --admin
}


function populate {
  if [ ! -d $HOME/src/superdesk$1/server ]; then
    echo "Server '$1' not found in $HOME/src/superdesk$1/server"
    exit 1
  fi

  python3 $HOME/src/superdesk$1/server/manage.py app:initialize_data
  python3 $HOME/src/superdesk$1/server/manage.py app:prepopulate
  python3 $HOME/src/superdesk$1/server/manage.py app:index_from_mongo --all
  user
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
