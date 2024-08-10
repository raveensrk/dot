#!/usr/bin/env bash


if [ ! -e ~/.fzf/bin/fzf ]; then
    git clone --depth 1 "git@github.com:junegunn/fzf.git" ~/.fzf
    "$HOME/.fzf/install" --all
fi
