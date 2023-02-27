#!/bin/bash

pushd ~/.tmp || exit 2
wget -nc https://github.com/neovim/neovim/releases/download/v0.8.2/nvim-linux64.tar.gz
tar xf nvim-linux64.tar.gz
pushd ~/.tmp/nvim-linux64 || exit 2
cp -rf ./* ~/.local
popd || exit 2
popd || exit 2
if [ ! -e ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
    git clone --depth 1 https://github.com/wbthomason/packer.nvim \
        ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi

nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
