#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]
then
  brew install jpeg libmagic libxmlsec1 zlib lzlib pkg-config docker-compose
else
  if [[ ! "$(whoami)" == "root" ]]
  then
    echo "Rerun this script as sudo"
    exit 1
  fi

  function add_apt_repositories {
    wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" > /etc/apt/sources.list.d/elasticsearch-2.x.list
    apt update
  }

  function install_apt_deps {
    apt install -y \
      libxmlsec1-dev \
      libjpeg-dev \
      zlib1g-dev \
      libtiff-dev \
      libfreetype6-dev \
      libwebp-dev \
      libraqm-dev \
      pkg-config
  }

  echo
  echo "Please install docker-compose manually"
  echo

  add_apt_repositories
  install_apt_deps
fi
