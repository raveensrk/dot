" PLUG FUNCTION CALL {{{
call plug#begin('~/.vim/plugged')

Plug 'git@github.com:airblade/vim-gitgutter'
Plug 'git@github.com:easymotion/vim-easymotion'
Plug 'git@github.com:junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'git@github.com:junegunn/fzf.vim'
Plug 'git@github.com:junegunn/vim-easy-align'
Plug 'git@github.com:liuchengxu/vim-which-key'
Plug 'git@github.com:mg979/vim-visual-multi', {'branch': 'master'}
Plug 'git@github.com:mhinz/vim-signify'
Plug 'git@github.com:morhetz/gruvbox'
Plug 'git@github.com:nathanaelkane/vim-indent-guides'
Plug 'git@github.com:tomtom/tcomment_vim'
Plug 'git@github.com:tpope/vim-markdown'
Plug 'git@github.com:tpope/vim-repeat'
Plug 'git@github.com:tpope/vim-sensible'
Plug 'git@github.com:tpope/vim-speeddating'
Plug 'git@github.com:tpope/vim-surround'
Plug 'git@github.com:tpope/vim-unimpaired'
Plug 'junegunn/vim-peekaboo'
Plug 'justinmk/vim-sneak'
Plug 'madox2/vim-ai'
Plug 'mhinz/vim-startify'
Plug 'rstacruz/vim-xtract'
Plug 'tpope/vim-vinegar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()
" }}}
" INDENT GUIDES{{{
let g:indent_guides_enable_on_vim_startup = 1
"}}}
" {{{ VIM SNEAK 
let g:sneak#label = 1
" }}}
"{{{ GIT GUTTER
set updatetime=100 " For gitgutter
"}}}
" AIRLINE{{{
let g:airline#extensions#tabline#enabled = 1
"}}}
" {{{ COLOR / THEME
colo gruvbox
" colo default
set background=dark
let g:gruvbox_contrast_dark="hard"
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
" }}}
"

