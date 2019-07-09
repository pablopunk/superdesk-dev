#!/bin/bash


if [[ "$(uname)" == "Darwin" ]]
then
  brew cask install homebrew/cask-versions/adoptopenjdk8
  brew install mongodb elasticsearch@2.4 redis python node jpeg libmagic
  brew services start redis
  brew services start mongo
  brew services start elasticsearch@2.4
  sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
else
  if [[ ! "$(whoami)" == "root" ]]
  then
    echo "Rerun this script as sudo"
    exit 1
  fi

  function add_apt_repositories {
    wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" > /etc/apt/sources.list.d/elasticsearch-2.x.list
    add-apt-repository -y ppa:webupd8team/java
    apt update
  }

  function install_apt_deps {
    apt install -y \
      mongodb-server \
      redis-server \
      elasticsearch \
      oracle-java8-installer \
      libxmlsec1-dev \
      pkg-config
  }

  add_apt_repositories
  install_apt_deps
fi
