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

The macOS shell configuration prepends Homebrew's GNU `coreutils` and `gawk`
command directories to `PATH`.

## If you use Ubuntu, install this

This script is for arm64/aarch64 only.

```sh
bash ~/dot/packages/ubuntu.sh
```

## Install vim plugins

```sh
bash ~/dot/config/vim/plugin/install_vim_plugins.sh
```

## Link app configs with stow

Dry-run first, then apply. See [docs/dotfiles-stow.md](docs/dotfiles-stow.md).

```sh
python3 ~/dot/script/install.py
python3 ~/dot/script/install.py --apply
```

On a machine where an app already wrote its own config, install aborts and
lists conflicts; `--backup` renames them, `--adopt` imports them into the repo.

## Other

Add paths to the list of all git repositories in this file. This is for `lg.py`.

```sh
/Users/$USER/dot_local/list_of_repositories.txt
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

## Test

Some text for testing.
aaaa

[example.sh](script/example.sh) prints `example ok` and exits 0. On `PATH`.

```sh
example.sh
```

[hello_world.sh](script/hello_world.sh) prints `hello world` and exits 0. On `PATH`.

```sh
hello_world.sh
```
