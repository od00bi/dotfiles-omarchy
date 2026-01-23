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
  read -p "init.sh: $prompt(y): " awnser
  if [[ "$awnser" == "y" ]]; then
    return 0
  else
    return 1
  fi
}

if [ -d ~/.dotfiles ]; then
  prompt 1 "Found existing dotfiles folder"
  if yesorno "Get the latest changes from remote?"; then
    if ! $dotfiles pull; then
      if yesorno "Git pull failed, checkout and try again?(y)"; then
        $dotfiles checkout -f
        $dotfiles pull
      else
        prompt 2 "Exiting"
        exit 1
      fi
    fi
  fi
else
  echo "init.sh: Cloning repo"
  /usr/bin/git clone --bare https://github.com/$repo ~/.dotfiles/.git
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
fi

if yesorno "Configure monitors?"; then
  /usr/bin/nvim ~/.config/hypr/monitors.conf
fi

prompt 1 "Setup complete"
