source $VIMRUNTIME/vimrc_example.vim
let g:pathogen_blacklist = ['Damian-Conway-s-Vim-Setup']

execute pathogen#infect()
syntax on
filetype plugin indent on

" HELP {{{
" Press <F1> for help
" K for help for word under cursor
" }}}
" BASICS {{{
set autoread
set mouse=a
set nocompatible
set hidden
set backspace=indent,eol,start
set encoding=utf-8
set noerrorbells
set novb t_vb=
" set vb t_vb=[?5h$<100>[?5l

" Use a line cursor within insert mode and a block cursor everywhere else.
"
" Reference chart of values:
"   Ps = 0  -> blinking block.
"   Ps = 1  -> blinking block (default).
"   Ps = 2  -> steady block.
"   Ps = 3  -> blinking underline.
"   Ps = 4  -> steady underline.
"   Ps = 5  -> blinking bar (xterm).
"   Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
" }}}
" NAVIGATION {{{
" set splitbelow splitright
" }}}
" GRAMMAR AND SEARCHING {{{
" set spell spelllang=en_us
" set textwidth=80
set isk+=-
set ignorecase
set smartcase
set dictionary="/usr/share/dict/words"
" }}}
" TABBING AND INDENT {{{
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set smarttab
" set listchars=nbsp:_,tab:>-,trail:~,extends:>,precedes:<,eol:$
" set list
" }}}
" FOLDING AND WRAPPING {{{
set foldmethod=marker
" }}}
" {{{ NUMBERING
" set nonumber norelativenumber
set nonumber 
" set relativenumber
" }}}
" {{{ INTERFACE
set wrap
set nolinebreak
set cursorline
set cursorlineopt=both
set nocursorcolumn
set hlsearch
set incsearch
set ruler
" set columns=80
" set colorcolumn=80
" highlight ColorColumn ctermbg=0 guibg=lightgrey
set wildmode=longest,list,full
set wildmenu
set wildignorecase
" set wildoptions=pum
" These 2 settings will force the cursor line to always be at the center of
" the screen
set scrolloff=999
set sidescrolloff=1

set virtualedit=all
" set textwidth=0 wrapmargin=0
" }}}
" {{{ BACKUPS AND UNDO
set noswapfile
set backup writebackup
set undofile
set undodir=~/.vim/undo
set backupdir=~/.vim/backup
" }}}
" {{{ NETRW
" let g:netrw_altv = 1
" let g:netrw_banner = 0
" let g:netrw_browse_split = 2
" let g:netrw_liststyle = 3
" let g:netrw_winsize = 25
" augroup ProjectDrawer
"   autocmd!
"   autocmd VimEnter * :Vexplore
" augroup END
let g:netrw_keepdir=0
autocmd FileType netrw silent! cd %:p:h
"}}}
" {{{ VIM SESSIONS AND VIEWS
" autocmd BufWinLeave *.* mkview!
" autocmd BufWinEnter *.* silent loadview
" augroup my_folding
"   au BufReadPre * setlocal foldmethod=indent
"   au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
" augroup END
" }}}
"{{{ FINALLY SOURCE CUSTOM PER USER CONGIFS

for f in split(glob('~/.my_vim_configs/*.vim'), '\n')
    exe 'source' f
endfor

"}}}
" ↑ WORKING CONFIGS ABOVE ↑
" ↓ TESTING ↓
let g:netrw_dirhistmax=1000

" set grepprg=grep\ -RnH\ $*\ --exclude=\"tags\"\ --exclude=\"TAGS\"\ /dev/null
set grepprg=rg\ --no-heading\ --with-filename\ --column\ --ignore-file\ $HOME/.scripts/.ignore\ $*

set showcmdloc="statusline"
set statusline=[%n]%m%r%f%=%h%w%y%q%k[%p%%][%04l,%04v][%L]%S
set previewpopup=height:10,width:60
set browsedir="buffer"
set title
set titlestring=%f
set titleold="Terminal"
set helpheight=10
function! Bookmarks()
    setlocal errorformat+=%f%.%#
    lexp  eval('g:netrw_bookmarklist')
    lopen 5
endfunction

set complete+=t
set completeopt+=popup,preview
set makeef=/tmp/errorfile
set foldclose="all"
set showfulltag
set showmatch
set verbosefile=/tmp/verbosefile
set whichwrap+=<,>,[,]
set equalalways
set winfixheight
set winfixwidth
set isfname-==
set isfname-=,
    autocmd FileType netrw cd %:p:h

packadd cfilter
set switchbuf=uselast
autocmd! BufEnter *.log setlocal readonly 
autocmd! BufEnter *.log setlocal wrap
autocmd QuickFixCmdPost make set wrap
autocmd QuickFixCmdPost make set nowinfixheight nowinfixwidth
set viminfo+=r/opt/homebrew/
set viminfo+=r~/.vim/plugged
set exrc secure
let mapleader = " "

" set path+=**;~/ " This is awesome but find search takes too long
set tags=./tags,../tags
set path+=*
set path+=.*
set path+=./;~/
set path+=~/my_repos
" runtime! plugin/**/*.vim

autocmd WinNew * wincmd =
    autocmd FileType sh set formatprg=shfmt\ % 
autocmd! BufWritePre
autocmd BufWritePre *.txt s/ \+$//e

" let &cdpath = ',' .. substitute(substitute($CDPATH, '[, ]', '\\\0', 'g'), ':', ',', 'g')
" set cdpath+="~/my_repos/dotfiles-main"
set cdpath+=~/my_repos/**
let g:ft_man_open_mode = 'vert'
let g:ft_man_folding_enable = 1
" autocmd FileType man setlocal foldmethod=indent foldenable
let g:ft_man_no_sect_fallback = 1
set keywordprg=:Man


