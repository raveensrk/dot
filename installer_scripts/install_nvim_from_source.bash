#!/bin/bash

pushd ~/.tmp || exit 2
wget -nc https://github.com/neovim/neovim/releases/download/v0.8.2/nvim-linux64.tar.gz
tar xf nvim-linux64.tar.gz
pushd ~/nvim-linux64 || exit 2
cp -rf ./* ~/.local
popd || exit 2
popd || exit 2
