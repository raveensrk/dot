#!/bin/bash

set -e
# set -x

# Basic files and directories setup
[ ! -d "$HOME/.tmp"        ] && mkdir "$HOME/.tmp"
[ ! -d "$HOME/.vim"        ] && mkdir "$HOME/.vim"
[ ! -d "$HOME/.vim/undo"   ] && mkdir "$HOME/.vim/undo"
[ ! -d "$HOME/.vim/backup" ] && mkdir "$HOME/.vim/backup"
[ ! -d "$HOME/.vim/swap"   ] && mkdir "$HOME/.vim/swap"
[ -d "$HOME/tmp" ]        || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
[ -d "$HOME/.status" ]    || mkdir -p "$HOME/.status"
[ -d "$HOME/.doom.d/my_elisp" ]    || mkdir -p "$HOME/.doom.d/my_elisp"
[ -e ~/.scripts/,clean_up_.DS_Store.bash ] && ~/.scripts/,clean_up_.DS_Store.bash

stow -R stow -t "$HOME" --no-folding

bash add_sources.bash "[ -f ~/.bash_aliases ] && source ~/.bash_aliases" "$HOME/.bashrc"
bash add_sources.bash "[ -f ~/.bashrc ] && source ~/.bashrc" "$HOME/.bash_login"

if [ "$is_linux" = "Darwin" ]; then
    stow -R stow_macos -t "$HOME" --no-folding
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
fi

is_linux=$(uname -a | cut -d ' ' -f 1)
if [ "$is_linux" = "Linux" ]; then
    stow -R stow_linux -t "$HOME" --no-folding
else
    echo Skipping linux stow command since this system is not linux...
fi

vim -c "PlugInstall | PlugClean | qa"
tldr -u
