call plug#begin('~/.vim/plugged')

Plug 'git@github.com:madox2/vim-ai.git'
Plug 'git@github.com:easymotion/vim-easymotion'
Plug 'git@github.com:junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'git@github.com:junegunn/fzf.vim'
Plug 'git@github.com:junegunn/vim-easy-align'
Plug 'git@github.com:liuchengxu/vim-which-key'
Plug 'git@github.com:morhetz/gruvbox'
Plug 'git@github.com:nathanaelkane/vim-indent-guides'
Plug 'git@github.com:tomtom/tcomment_vim'
Plug 'git@github.com:tpope/vim-repeat'
Plug 'git@github.com:tpope/vim-sensible'
Plug 'git@github.com:tpope/vim-surround'
Plug 'git@github.com:tpope/vim-unimpaired'
Plug 'junegunn/vim-peekaboo'
Plug 'justinmk/vim-sneak'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-vinegar'

call plug#end()

let g:indent_guides_enable_on_vim_startup = 0
let g:sneak#label = 1
colo gruvbox
set background=dark
let g:gruvbox_contrast_dark="hard"
