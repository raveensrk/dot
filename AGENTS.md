# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## What This Repo Is

This is a personal dotfiles repository (`~/dot`) for macOS and Ubuntu. It manages shell configuration, editor setup, and a collection of utility scripts.

## Directory Layout

- `config/` — Configuration files: `bashrc`, `vimrc`, `gitconfig`, `tmux/`, `vim/`, `prompt`, `inputrc`, `taskrc`, etc.
- `script/` — Utility scripts added to `$PATH` (both `~/dot/script` and `~/script` are on PATH)
- `bin/` — Additional scripts on PATH (`~/dot` symlinks likely handled manually)
- `packages/` — OS-specific install scripts (`macos.sh`, `ubuntu.sh`, `pip_packages.sh`, etc.)
- `tests/` — Integration tests
- `unit_test/` — Unit tests
- `practice/` — Small practice files (Python, etc.)
- `audio/` — Sound files used by notification scripts

## Bootstrap / Installation

```sh
# Change shell to Homebrew bash
sudo vim /etc/shells  # add /opt/homebrew/bin/bash
chsh -s /opt/homebrew/bin/bash

# Add to ~/.bashrc
eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/dot/config/bashrc
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Install macOS packages
bash ~/dot/packages/macos.sh

# Install Ubuntu packages (arm64/aarch64 only)
bash ~/dot/packages/ubuntu.sh

# Install vim plugins
bash ~/dot/config/vim/plugin/install_vim_plugins.sh
```

## Script Architecture

### Core Shell Libraries (sourced by `header.sh`)

Scripts that source `$DOT/script/header.sh` get access to:

- **`colors.sh`** — Color variables (`$green`, `$red`, `$yellow`, `$nocolor`, etc.) and echo helpers: `echog` (green/PASS), `echor` (red/FAIL), `echoy` (yellow)
- **`require.sh`** — Guard functions: `require_file`, `require_dir`, `require_cmd`, `require_var`, `source_if_exists`
- **`box.sh`** — `box()` function that prints a `PART:` section header in magenta

`header.sh` also provides: `pushd2`, `popd2`, `change_to_script_dir`, `mkdirf`, `mkdir2`, `rm_mkdir`

### Environment

- `$DOT` is always `$HOME/dot`
- `$PATH` includes `$HOME/script`, `$DOT/script`, `$HOME/.local/bin`
- Editor is `vim` (via `$EDITOR`/`$VISUAL`)
- Vimrc is loaded from `$DOT/config/vimrc` via `$VIMINIT`
- Inputrc is loaded from `$DOT/config/inputrc` via `$INPUTRC`

### Script Conventions

- Scripts use `#!/usr/bin/env bash` and require Bash 5+
- Exit with code `2` (not `1`) for failures — `check_bash_version` and guards use `return 2`
- Use `echor`/`echog`/`echoy` instead of raw `echo` for status messages
- Color variables are exported (`declare -x`) — available in subshells

### `lg.py` — Multi-repo Git Status

The `lg.py` script reads from `/Users/$USER/script/list_of_repositories.txt` to show git status across multiple repos. Add repo paths there to include them.

## Vim Setup

- Uses [pathogen](https://github.com/tpope/vim-pathogen) for plugin management
- Plugin directory: `~/dot/config/vim/plugin/`
- `dot_local/config/vim/` can override with machine-local config
- Vimrc sources `$VIMRUNTIME/vimrc_example.vim` as base

## Key Tools Expected on PATH

`bat`, `fzf`, `ripgrep`, `lazygit`, `ranger`, `pandoc`, `shellcheck`, `shfmt`, `universal-ctags`, `jq`, `tmux`, `taskwarrior`
