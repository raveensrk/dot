source $VIMRUNTIME/vimrc_example.vim

" HELP {{{
" Press <F1> for help
" Press <F3> for help for word under cursor
" :map <F3> "zyiw:exe "h ".@z.""<CR>
map <F3> "zyiw:exe "h ".@z<CR>
" }}}
" BASICS {{{
set autoread
set mouse=a
set nocompatible
filetype plugin on
syntax on
" set hidden
set backspace=indent,eol,start
set encoding=utf-8
" set vb t_vb=[?5h$<100>[?5lsd
set noerrorbells
set novb t_vb=
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
set title
"set splitbelow splitright
" }}}
" GRAMMAR AND SEARCHING {{{
" set spell spelllang=en_us
set textwidth=80
set isk+=-
set ignorecase
set smartcase
set incsearch
set dictionary="/usr/share/dict/words"
" }}}
" TABBING AND INDENT {{{
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
" set listchars=nbsp:_,tab:>-,trail:~,extends:>,precedes:<
" set list
" }}}
" FOLDING AND WRAPPING {{{
set foldmethod=marker
" }}}
" {{{ NUMBERING
" set nonumber norelativenumber
set number 
" set relativenumber
" set listchars=eol:$
" set listchars=nbsp:_,tab:>-,trail:~,extends:>,precedes:<
" set list
" }}}
" {{{ INTERFACE
set wrap
set cursorline
set cursorcolumn
set hlsearch
set ruler
"set columns=80
set colorcolumn=80
"highlight ColorColumn ctermbg=0 guibg=lightgrey
" set wildmode=longest,list,full
set wildmenu
set wildoptions=pum
" These 2 settings will force the cursor line to always be at the center of
" the screen
set scrolloff=999
set sidescrolloff=999

" set virtualedit=all
set textwidth=0 wrapmargin=0
" }}}
" {{{ BACKUPS AND UNDO
set noswapfile
set backup writebackup
set undofile
set undodir=~/.vim/undo
set backupdir=~/.vim/backup
" }}}
" {{{ DISBALED - TRIM WHITE SPACE AFTER EXIT
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
" autocmd BufWritePre * :call TrimWhitespace()
" }}}
" CTAGS {{{
set tags=tags
" }}}
" {{{ PATH
set path+=**
set autochdir
" set noautochdir " This will change your pwd to current file
" }}}
" FILE SPECIFIC {{{
autocmd BufRead .vimrc :set foldmethod=marker
" }}}
" {{{1 RESOURCE PLUGIN DIRECTORY
" This is done so the plugin directory is sourced again at the end of this
" vimrc file. This will make plugins work properly

" ~/.vim/plugin
for f in split(glob('~/.vim/plugin/*.vim'), '\n')
    exe 'source' f
endfor

" }}}
"{{{ FINALLY SOURCE CUSTOM PER USER CONGIFS

for f in split(glob('~/.my_vim_configs/*.vim'), '\n')
    exe 'source' f
endfor

"}}}
"{{{ FOLDING
let g:markdown_folding = 1
noremap <2-LeftMouse> za
"}}}
"{{{ CLIPBOARD
vmap <silent> +y :w! ~/.vim_clip<cr>
nmap <silent> +p :read ~/.vim_clip<cr>

set clipboard=unnamed
"}}}
" {{{ VIM SESSIONS AND VIEWS
autocmd BufWinLeave *.* mkview!
autocmd BufWinEnter *.* silent loadview
" augroup my_folding
"   au BufReadPre * setlocal foldmethod=indent
"   au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
" augroup END
" }}}
