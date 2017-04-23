#!/usr/bin/bash

if [ "$(/bin/whoami)" != 'git' ]; then
  echo "This script have to be performed only by git user!"
  exit 1
fi

cd /home/git/
git clone https://github.com/sitaramc/gitolite.git
mkdir -p $HOME/bin
gitolite/install -to $HOME/bin
$HOME/bin/gitolite setup -pk admin.pub