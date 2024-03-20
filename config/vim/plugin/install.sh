#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
# set -x

curl -LSso ~/dot/config/vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
git clone 'git@github.com:ctrlpvim/ctrlp.vim.git' ~/.vim/bundle/ctrlp
git clone 'git@github.com:easymotion/vim-easymotion' ~/.vim/bundle/vim-easymotion
git clone 'git@github.com:junegunn/vim-easy-align' ~/.vim/bundle/vim-easy-align
git clone 'git@github.com:justinmk/vim-sneak.git' ~/.vim/bundle/vim-sneak
git clone 'git@github.com:liuchengxu/vim-which-key' ~/.vim/bundle/vim-which-key
git clone 'git@github.com:madox2/vim-ai.git' ~/.vim/bundle/vim-ai.git
git clone 'git@github.com:mg979/vim-visual-multi' ~/.vim/bundle/vim-visual-multi
git clone 'git@github.com:mhinz/vim-signify' ~/.vim/bundle/vim-signify
git clone 'git@github.com:morhetz/gruvbox' ~/.vim/bundle/gruvbox
git clone 'git@github.com:nathanaelkane/vim-indent-guides' ~/.vim/bundle/vim-indent-guides
git clone 'git@github.com:pelodelfuego/vim-swoop.git' ~/.vim/bundle/vim-swoop
git clone 'git@github.com:preservim/tagbar.git' ~/.vim/bundle/tagbar
git clone 'git@github.com:tomtom/tcomment_vim' ~/.vim/bundle/tcomment_vim
git clone 'git@github.com:tpope/vim-eunuch' ~/.vim/bundle/vim-eunuch
git clone 'git@github.com:tpope/vim-fugitive' ~/.vim/bundle/vim-fugitive
git clone 'git@github.com:tpope/vim-repeat' ~/.vim/bundle/vim-repeat
git clone 'git@github.com:tpope/vim-sensible' ~/.vim/bundle/vim-sensible
git clone 'git@github.com:tpope/vim-speeddating.git' ~/.vim/bundle/vim-speeddating
git clone 'git@github.com:tpope/vim-surround' ~/.vim/bundle/vim-surround
git clone 'git@github.com:tpope/vim-unimpaired' ~/.vim/bundle/vim-unimpaired
git clone 'git@github.com:tpope/vim-vinegar' ~/.vim/bundle/vim-vinegar
git clone 'git@github.com:yegappan/taglist.git' ~/.vim/bundle/taglist
git clone 'https://github.com/MattesGroeger/vim-bookmarks.git' ~/.vim/bundle/vim-bookmarks
git clone 'https://github.com/dense-analysis/ale' ~/.vim/bundle/ale
git clone 'https://github.com/gcmt/taboo.vim.git' ~/.vim/bundle/taboo.vim
git clone 'https://github.com/itchyny/lightline.vim.git' ~/.vim/bundle/lightline.vim
git clone 'https://github.com/mechatroner/rainbow_csv' ~/.vim/bundle/rainbow_csv
git clone 'https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup' ~/.vim/bundle/Damian-Conway-s-Vim-Setup
git clone 'https://github.com/vim-scripts/YankRing.vim.git' ~/.vim/bundle/YankRing
git clone https://github.com/MarcWeber/vim-addon-qf-layout.git ~/.vim/bundle/vim-addon-qf-layout
git clone https://github.com/chrisbra/Colorizer ~/.vim/bundle/Colorizer
