#!/opt/homebrew/bin/bash

git clone --depth 1 "git@github.com:junegunn/fzf.git" ./stow_vim_plugins/.fzf

stow -R stow_vim_plugins -t "$HOME"

"$HOME/.fzf/install" --all
