#!/usr/bin/bash

dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME"

first_time_configuration () {
  $dotfiles config status.showUntrackedFiles no

  /usr/bin/notify-send "intit.sh: Configure your preferred monitor setup and exit"
  # The monitor setup is different for every new host, but I always have to configure it once depending on scale, orientation etc
  /usr/bin/nvim ~/.config/hypr/monitors.conf
}

if [ -d ~/.dotfiles ]; then
  echo "Found existing dotfiles folder"
  if ! $dotfiles pull; then
    echo -n "Git pull failed, checkout and try again?(y): "
    read again
    if [ $again = "y" ]; then
      $dotfiles checkout -f
      $dotfiles pull
    else
      echo "init.sh: exiting"
      exit 1
    fi
  fi
else
  echo "Running first-time setup"
  FIRST_TIME=true
  /usr/bin/git clone --bare https://github.com/od00bi/dotfiles-omarchy-test.git ~/.dotfiles/.git
fi

$dotfiles checkout -f

if ! command -v /usr/bin/ansible > /dev/null; then
  sudo /usr/bin/pacman -S ansible
fi

/usr/bin/ansible-playbook -c local --ask-become-pass ~/.dotfiles/general.yml

if [ "$FIRST_TIME" = true ]; then
  first_time_configuration
fi
