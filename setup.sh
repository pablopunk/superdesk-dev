#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]
then
  brew tap mongodb/brew
  brew cask install homebrew/cask-versions/adoptopenjdk8
  brew install mongodb-community elasticsearch@2.4 redis node jpeg libmagic libxmlsec1
  brew services start redis
  brew services start mongodb-community
  brew services start elasticsearch@2.4
  sudo pip3 install --upgrade setuptools pip
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
      mongodb-server \
      redis-server \
      openjdk-8-jre \
      elasticsearch \
      libxmlsec1-dev \
      libjpeg-dev \
      zlib1g-dev \
      libtiff-dev \
      libfreetype6-dev \
      libwebp-dev \
      libraqm-dev \
      pkg-config
  }

  add_apt_repositories
  install_apt_deps
fi
