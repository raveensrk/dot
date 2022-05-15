" Plugins {{{
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/tpope/vim-sensible'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
" Plug 'vim/killersheep'
Plug 'frazrepo/vim-rainbow'
" Plug 'vim-airline/vim-airline'
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
Plug 'https://github.com/yoshi1123/vim-linebox'

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

Plug 'https://github.com/mechatroner/rainbow_csv'
Plug 'https://github.com/yegappan/taglist'
" Plug 'https://github.com/fholgado/minibufexpl.vim'
Plug 'https://github.com/ervandew/supertab'
Plug 'ledger/vim-ledger'

call plug#end()

" MBE
" MiniBufExpl Colors
" hi MBENormal               guifg=#808080 guibg=fg
" hi MBEChanged              guifg=#CD5907 guibg=fg
" hi MBEVisibleNormal        guifg=#5DC2D6 guibg=fg
" hi MBEVisibleChanged       guifg=#F1266F guibg=fg
" hi MBEVisibleActiveNormal  guifg=#A6DB29 guibg=fg
" hi MBEVisibleActiveChanged guifg=#F1266F guibg=fg


" Linebox

let g:linebox_default_maps = 0
let g:linebox_marks = ["'a", "'b"]
let g:linebox_animation = 1

nnoremap <leader><leader>L :call linebox#lines#line(g:linebox_marks[0], g:linebox_marks[1])<cr>
nnoremap <leader><leader>b :call linebox#boxes#box()<cr>
vnoremap <leader><leader>b :call linebox#boxes#box()<cr>
nnoremap <leader><leader>B :call linebox#boxes#mbox()<cr>
vnoremap <leader><leader>B :call linebox#boxes#mbox()<cr>



let g:session_autoload = 'no'

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
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
" }}}
