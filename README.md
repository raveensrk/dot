# README

## Change shell to bash if required

```sh
chsh -s /bin/bash
# or
chsh -s /opt/homebrew/bin/bash
```

## Install Homebrew on macOS

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Add the following to your .bashrc

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/dot/config/bashrc
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
```

## Create an SSH key if needed

```sh
ssh-keygen
```

## Install GitHub CLI (gh)

```sh
brew install gh
gh auth login
```

## Clone this repo with

```sh
git clone git@github.com:raveensrk/dot
```

## Install macOS-specific packages

Install MacPorts:

```sh
https://www.macports.org/install.php
```

Install all other packages:

```sh
bash ~/dot/packages/macos.sh
```

## If you use Ubuntu, install this

This script is for arm64/aarch64 only.

```sh
bash ~/dot/packages/ubuntu.sh
```

## Install vim plugins

```sh
bash ~/dot/config/vim/plugin/install_vim_plugins.sh
```

## Other

Add paths to the list of all git repositories in this file. This is for `lg.py`.

```sh
/Users/$USER/script/list_of_repositories.txt
```

## macOS: Basic setup

### Change bash to Homebrew bash

Change the default shell to the Homebrew shell.

```sh
sudo vim /etc/shells
```

Add this line:

```txt
/opt/homebrew/bin/bash
```

Then change the shell:

```sh
chsh -s /opt/homebrew/bin/bash
```

### Settings

> Settings -> Keyboard -> Key Repeat Rate = Fast

> Settings -> Keyboard -> Delay Until Repeat = Short

### Terminal

> Settings -> Profiles -> Keyboard -> Enable "Use Option as Meta Key"
