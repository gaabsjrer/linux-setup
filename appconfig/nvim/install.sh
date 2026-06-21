#!/bin/bash

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

# get the path to this script
APP_PATH=`dirname "$0"`
APP_PATH=`( cd "$APP_PATH" && pwd )`

unattended=0
subinstall_params=""
for param in "$@"
do
  echo $param
  if [ $param="--unattended" ]; then
    echo "installing in unattended mode"
    unattended=1
    subinstall_params="--unattended"
  fi
done

distro=`lsb_release -r | awk '{ print $2 }'`

default=y
while true; do
  if [[ "$unattended" == "1" ]]
  then
    resp=$default
  else
    [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mInstall NEOVIM? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
  fi
  response=`echo $resp | sed -r 's/(.*)$/\1=/'`

  if [[ $response =~ ^(y|Y)=$ ]]
  then

    echo Installing neovim

		# neovim installation
 		sudo apt install -y software-properties-common

		sudo add-apt-repository ppa:neovim-ppa/stable -y
		sudo apt-get update
		sudo apt-get install neovim

		# set .config nvim folder
    cd $APP_PATH/../../submodules/nvim
    mkdir -p ~/.config/nvim

    ln -sf $APP_PATH/../vim/dotvim/* ~/.config/nvim/

    ln -sf $APP_PATH/doc/* ~/.config/nvim/doc
    ln -sf $APP_PATH/lua/* ~/.config/nvim/lua
    ln -fs $APP_PATH/.stylua.toml/ ~/.config/nvim/.stylua.toml
    ln -fs $APP_PATH/init.lua/ ~/.config/nvim/.init.lua
    ln -fs $APP_PATH/laze-lock.json/ ~/.config/nvim/laze-lock.json


		echo -e "# set nvim as the editor\nEDITOR=nvim" >> ~/.bashrc

    break
  elif [[ $response =~ ^(n|N)=$ ]]
  then
    break
  else
    echo " What? \"$resp\" is not a correct answer. Try y+Enter."
  fi
done
