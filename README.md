# README

## Change shell to bash if required

```sh
chsh -s /bin/bash
```

## Install brew in macos

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Add the following to your .bashrc

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/dot/config/bashrc
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
```

## Install MacOS specific packages

Install macport

```sh
https://www.macports.org/install.php
```

Install all other packages

```sh
bash ~/dot/packages/macos.sh
```

## If you use ubuntu install this

This script is for arm64/aarch64 only

```sh
bash ~/dot/packages/ubuntu.sh
```

## Install vim plugins

```sh
bash ~/dot/config/vim/plugin/install_vim_plugins.sh
```

## Other

Add paths to list of all git repositories to this file. This is for `lg.py`
script

```sh
/Users/raveen_kumar_work/script/list_of_repositories.txt
```

## MacOS: Basic setup

### Change bash to homebrew bash

Change the default shell to the homebrew shell

```sh
sudo vim /etc/shells
```

add this line

```txt
/opt/homebrew/bin/bash
```

Then change the shell

```sh
chsh -s /opt/homebrew/bin/bash
```

### Settings

> Settings -> Keyboard -> Key Repeat Rate = Fast

> Settings -> Keyboard -> Delay Until Repeat = Short

### Terminal

> Settings -> Profiles -> Keyboard -> Enable "Use Option as Meta Key"
