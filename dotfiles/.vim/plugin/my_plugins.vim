" Plugins {{{
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
Plug 'vim/killersheep'
Plug 'frazrepo/vim-rainbow'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'junegunn/vim-easy-align'
Plug 'godlygeek/tabular'
Plug 'mattn/emmet-vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
" https://github.com/mg979/vim-visual-multi
Plug 'airblade/vim-gitgutter'
Plug 'terryma/vim-expand-region'
Plug 'dense-analysis/ale'
Plug 'tommcdo/vim-exchange'
" Plug 'svermeulen/vim-yoink'
Plug 'tpope/vim-fugitive'
Plug 'xolox/vim-easytags'
Plug 'xolox/vim-misc'
Plug 'preservim/tagbar'
Plug 'mhinz/vim-signify'
Plug 'https://github.com/azabiong/vim-highlighter'
call plug#end()

set updatetime=100 " For gitgutter

nmap <F8> :TagbarToggle<CR>

let g:rainbow_active = 1
let g:airline#extensions#tabline#enabled = 1

" Vim Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Vim Expand Region
map K <Plug>(expand_region_expand)
map J <Plug>(expand_region_shrink)
"}}}
" {{{ COLOR / THEME
colo gruvbox
" colo default
set background=dark
" }}}
