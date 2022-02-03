" Plugins {{{
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/tpope/vim-sensible'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
" Plug 'vim/killersheep'
Plug 'frazrepo/vim-rainbow'
Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
" Plug 'junegunn/vim-easy-align'
" Plug 'mattn/emmet-vim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
" https://github.com/mg979/vim-visual-multi
Plug 'airblade/vim-gitgutter'
" Plug 'terryma/vim-expand-region'
" Plug 'dense-analysis/ale'
" Plug 'tommcdo/vim-exchange'
" Plug 'svermeulen/vim-yoink'
" Plug 'tpope/vim-fugitive'
" Plug 'xolox/vim-easytags'
" Plug 'xolox/vim-misc'
" Plug 'preservim/tagbar'
Plug 'mhinz/vim-signify'
Plug 'https://github.com/azabiong/vim-highlighter'
Plug 'https://github.com/vim-syntastic/syntastic'
"Plug 'jceb/vim-orgmode'

" Plug 'godlygeek/tabular'
" Plug 'plasticboy/vim-markdown'
"
Plug 'https://github.com/tpope/vim-markdown'

Plug 'liuchengxu/vim-which-key'
Plug 'https://github.com/xolox/vim-misc'
Plug 'https://github.com/xolox/vim-session'

Plug 'https://github.com/tpope/vim-speeddating'

" Plug 'nmaiti/fzf_cscope.vim' " This doesnot work
" @TODO try Rg or Ag with fzf
" @TODO Check for better fzf cscope plugins

" On-demand lazy load
" Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
"
" " To register the descriptions when using the on-demand load feature,
" " use the autocmd hook to call which_key#register(), e.g., register for the
" Space key:
" " autocmd! User vim-which-key call which_key#register('<Space>',
" 'g:which_key_map')

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

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>


"}}}
" {{{ COLOR / THEME
colo gruvbox
" colo default
set background=dark
" }}}
