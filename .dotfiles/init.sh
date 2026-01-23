#!/usr/bin/bash

dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME"
repo="od00bi/dotfiles-omarchy.git"

prompt () {
  local level_num=$1
  local prompt=$2
  case "$level_num" in
    1) level_string="INFO" ;;
    2) level_string="WARNING" ;;
    3) level_string="ERROR" ;;
    *) level_string="INFO" ;;
  esac
  echo "init.sh: [$level_string] $prompt"
}

yesorno () {
  local prompt="$1"
  read -p "init.sh: [INPUT] $prompt(y): " awnser
  if [[ "$awnser" == "y" ]]; then
    return 0
  else
    return 1
  fi
}

if omarchy-update-available; then
  prompt 1 "Updating the system"
  omarchy-update
fi

/usr/bin/mkdir -p repos

if [ -d ~/.dotfiles ]; then
  prompt 1 "Found existing dotfiles folder"
else
  prompt 1 "Cloning dotfiles-omarchy repo"
  /usr/bin/git clone --bare https://github.com/$repo ~/.dotfiles/.git
fi

if [ -d ~/repos/dotfiles-generic ]; then
  prompt 1 "Found existing dotfiles-generic folder"
else
  prompt 1 "Cloning dotfiles-generic repo"
  /usr/bin/git clone https://github.com/od00bi/dotfiles-generic ~/repos/dotfiles-generic
fi

$dotfiles checkout -f

if ! command -v /usr/bin/ansible > /dev/null; then
  sudo /usr/bin/pacman -S ansible
fi

/usr/bin/ansible-playbook -c local --ask-become-pass ~/.dotfiles/general.yml

$dotfiles config status.showUntrackedFiles no

if yesorno "Chagne repo remote to ssh?"; then
  $dotfiles remote rm origin
  $dotfiles remote add origin git@github.com:$repo
  $dotfiles branch --set-upstream-to=origin/main main
  cd ~/repos/dotfiles-generic && /usr/bin/git remote rm origin
  cd ~/repos/dotfiles-generic && /usr/bin/git remote add origin git@github.com:od00bi/dotfiles-generic
  cd ~/repos/dotfiles-generic && /usr/bin/git branch --set-upstream-to=origin/main main
fi

if yesorno "Configure monitors?"; then
  /usr/bin/nvim ~/.config/hypr/monitors.conf
fi

prompt 1 "Setup complete"
