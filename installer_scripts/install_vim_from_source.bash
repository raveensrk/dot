#!/bin/bash 

pushd ~/.tmp || exit 2
# wget -nc https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2
# tar xf vim-8.2.tar.bz2
# pushd vim82 || exit 2

git clone git@github.com:vim/vim.git
pushd vim || exit 2
./configure --prefix="$HOME/.local" --disable-gui --without-x
make
make install
popd || exit 2
popd || exit 2
exit 0
