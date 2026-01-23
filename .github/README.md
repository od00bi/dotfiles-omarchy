# dotfiles-omarchy

My omarchy dotfiles.

## Usage

### First time

To set up for the first time, run the init bash script:

```sh 
curl https://raw.githubusercontent.com/od00bi/dotfiles-omarchy/refs/heads/main/.dotfiles/init.sh | sh
```

The script will clone the repo if it does not exist, install ansible and run some "first-time" setup commands.

### Updating

1. Pull the repo and checkout from main.

```sh
git pull
git checkout -f
```

2. Run the ansible playbook

```sh
ansible-playbook -c local ~/.dotfiles/general.yml --ask-become-pass
```
