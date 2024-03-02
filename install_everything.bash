#!/bin/bash

set -e
# set -x

[ ! -d "$HOME/.vim"        ] && mkdir -p "$HOME/.vim"
[ ! -d "$HOME/.vim/undo"   ] && mkdir -p "$HOME/.vim/undo"
[ ! -d "$HOME/.vim/backup" ] && mkdir -p "$HOME/.vim/backup"
[ ! -d "$HOME/.vim/swap"   ] && mkdir -p "$HOME/.vim/swap"
[ ! -d "$HOME/tmp"         ] && mkdir -p "$HOME/tmp"
[ ! -d "$HOME/.local/bin"  ] && mkdir -p "$HOME/.local/bin"
[ ! -d "$HOME/.mutt/cache/headers"  ] && mkdir -p "$HOME/.mutt/cache/headers"
[ ! -d "$HOME/.mutt/cache/bodies"  ] && mkdir -p "$HOME/.mutt/cache/bodies"


stow  -R  stow  -t "$HOME" --no-folding

is_linux=$(uname -a | cut -d ' ' -f 1)

if [ "$is_linux" = "Darwin" ]; then
    stow -R stow_macos -t "$HOME" --no-folding
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
fi

if [ "$is_linux" = "Linux" ]; then
    stow -R stow_linux -t "$HOME" --no-folding
fi
