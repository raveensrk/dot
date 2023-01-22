#!/bin/bash 

pushd $HOME/.tmp
git clone "git@github.com:todotxt/todo.txt-cli.git"
pushd "todo.txt-cli-master"
make
make install \
    CONFIG_DIR=$HOME/.local/etc \
    INSTALL_DIR=$HOME/.local/bin \
    BASH_COMPLETION=$HOME/.local/share/bash-completion/completions

make test

popd

popd
