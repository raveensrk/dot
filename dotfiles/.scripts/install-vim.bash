#!/bin/bash

[ ! -d ~/.vim/undo ] && mkdir -p ~/.vim/undo
[ ! -d ~/.vim/backup ] && mkdir -p ~/.vim/backup
[ ! -d ~/.vim/swap ] && mkdir -p ~/.vim/undo


curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
