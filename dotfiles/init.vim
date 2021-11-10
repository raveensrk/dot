" Plugins {{{
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'vim/killersheep'
Plug 'frazrepo/vim-rainbow'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'junegunn/vim-easy-align'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'mattn/emmet-vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
" https://github.com/mg979/vim-visual-multi
Plug 'airblade/vim-gitgutter'
Plug 'terryma/vim-expand-region'
Plug 'dense-analysis/ale'
call plug#end()

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
