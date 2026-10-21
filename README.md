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

## Install

`install.sh` is the one entry point; `uninstall.sh` undoes it. Both dry-run
first and change nothing until `--apply`. The steps and flags live in their
headers: `~/dot/install.sh help`.

```sh
~/dot/install.sh
~/dot/install.sh --apply
~/dot/uninstall.sh --apply
```

`install.sh` points Ghostty at this repo, runs
[lib/agents.py](lib/agents.py) (pi, Claude Code and Codex config, no
symlinks, then agent1), every other `install.py` under `~/repos`, and the pi
timeout label patch. Registering the Claude plugins needs the `claude` CLI on
`PATH`; the installer prints the install command when it is missing.

### System packages

A new machine also wants its packages and vim plugins. They need a network and
sudo, so they run only when asked:

```sh
~/dot/install.sh --packages --apply
```

That runs [packages/macos.sh](packages/macos.sh) or, elsewhere,
[packages/ubuntu.sh](packages/ubuntu.sh) (arm64/aarch64 only), then
[config/vim/plugin/install_vim_plugins.sh](config/vim/plugin/install_vim_plugins.sh).
On macOS install MacPorts first: https://www.macports.org/install.php. The
macOS shell configuration prepends Homebrew's GNU `coreutils` and `gawk`
command directories to `PATH`.

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
