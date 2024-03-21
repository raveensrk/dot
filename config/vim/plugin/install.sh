#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
# set -x

[ -d ~/.vim/bundle ] && rm -rf ~/.vim/bundle
mkdir -p ~/.vim/bundle && cd ~/.vim/bundle
mkdir -p ~/.vim/autoload
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim &
git clone 'git@github.com:easymotion/vim-easymotion' &
git clone 'git@github.com:junegunn/vim-easy-align' &
git clone 'git@github.com:mhinz/vim-signify' &
git clone 'git@github.com:nathanaelkane/vim-indent-guides' &
git clone 'git@github.com:tomtom/tcomment_vim' &
git clone 'git@github.com:tpope/vim-eunuch' &
git clone 'git@github.com:tpope/vim-fugitive' &
git clone 'git@github.com:tpope/vim-repeat' &
git clone 'git@github.com:tpope/vim-sensible' &
git clone 'git@github.com:tpope/vim-speeddating.git' &
git clone 'git@github.com:tpope/vim-surround' &
git clone 'git@github.com:tpope/vim-unimpaired' &
git clone 'git@github.com:tpope/vim-dispatch' &
git clone 'git@github.com:tpope/vim-vinegar' &
git clone 'git@github.com:yegappan/taglist.git' &
git clone 'https://github.com/dense-analysis/ale' &
git clone 'https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup' &
git clone https://github.com/MarcWeber/vim-addon-qf-layout.git &
git clone https://github.com/chrisbra/unicode.vim.git &
git clone https://github.com/wuelnerdotexe/vim-enfocado &
wait
