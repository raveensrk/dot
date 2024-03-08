#!/usr/bin/env bash

cat << HERE
git clone https://github.com/vim/vim.git 
cd vim
./configure --prefix="$HOME/.local"  --with-features="huge" --enable-python3interp --enable-autoservername --with-x --disable-gui
make -j
make install
HERE
