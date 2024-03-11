#!/usr/bin/env bash

git clone https://github.com/vim/vim.git 
cd vim || exit
./configure --prefix="$HOME/.local"  --with-features="huge" --enable-python3interp --enable-autoservername --disable-gui
make -j
make install
