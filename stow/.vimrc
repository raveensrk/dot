source $VIMRUNTIME/vimrc_example.vim

" Help {{{
" Press <F1> for help
" Press <F3> for help for word under cursor
" :map <F3> "zyiw:exe "h ".@z.""<CR>
map <F3> "zyiw:exe "h ".@z<CR>
" }}}
" BASICS {{{
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
set noautochdir " This will change your pwd to current file
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
set nonumber norelativenumber
" set number relativenumber
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
set wildmode=longest,list,full
set wildmenu

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
" TRIM WHITE SPACE AFTER EXIT - DISBALED {{{
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
" }}}
" FILE SPECIFIC {{{
autocmd BufRead .vimrc :set foldmethod=marker
" }}}
" ***DISABLED*** Copy Paste to/from Vim/system clipboard {{{
" vnoremap <leader>y "+y
" vnoremap <leader>x "+x
" nnoremap <leader>p "+p
" vnoremap <leader>y "+y
" vnoremap <leader>x "+x
" nnoremap <leader>p "+p
" }}}
" {{{ CUSTOM KEYMAPS
let mapleader = " "

"noremap <Up> <NOP>
"noremap <Down> <NOP>
"noremap <Left> <NOP>
"noremap <Right> <NOP>

" Browse recent files
nnoremap <leader>h :History<CR>

" Navigate previous and next buffers respectively
nnoremap <leader><Left> :bp<CR>
nnoremap <leader><Right> :bn<CR>

" Write quit shortcut FINALLY!!!!!!!!!!!!!!
" -----------------------------------------------
nnoremap <leader>w   :w<CR>
nnoremap <leader>wq  :wq<CR>
nnoremap <leader>wqa :wqa<CR>
nnoremap <leader>q   :q<CR>
nnoremap <leader>qq  :q!<CR>
nnoremap <leader>qa  :qa<CR>
nnoremap <leader>qqa :qa!<CR>

nnoremap <leader>a ggVG
nnoremap <leader>y mmggVGy'm

" Other time savers
" -------------------------------
nnoremap <leader>dm  :set diffopt=filler,context:0<CR>
nnoremap <leader>e   :Ex<CR>jj
nnoremap <leader>pi :PlugClean<CR>:PlugInstall<CR>
nnoremap <leader>vrc :e $MYVIMRC<CR>
nnoremap <leader>src :b ~/.vimrc<CR>:w<CR>:source ~/.vimrc<CR>
nnoremap <silent> <Leader>+ :vertical resize +5<CR>
nnoremap <silent> <Leader>- :vertical resize -5<CR>

" Move blocks on lines in visual mode
vnoremap <Up>   :move -2<CR>gv=gv
vnoremap <Down> :move +2<CR>gv=gv

" Move single lines in normal mode
nnoremap <Up>   :move -2<CR>
nnoremap <Down> :move +1<CR>

" TODO Move vertial lines left or right in visual mode

nnoremap <leader>ac :s/ --/\r--/g<CR>

nnoremap <leader><tab> za

" Execute current line in Vim Ex mode
nnoremap <leader>x yyq:p<CR>

" Execute current line in bash and return the results few lines below within a
" fold
nnoremap <leader><leader>x yyo<cr># {{{<Esc>q:pIread ! <Esc><CR>o# }}}<Esc>

" {{{2 Map meta key to movement 
nnoremap n h
nnoremap e j
nnoremap i k
nnoremap o l
vnoremap n h
vnoremap e j
vnoremap i k
vnoremap o l


" }}}
" {{{1 Resource plugin directory
" This is done so the plugin directory is sourced again at the end of this
" vimrc file. This will make plugins work properly

" ~/.vim/plugin
for f in split(glob('~/.vim/plugin/*.vim'), '\n')
    exe 'source' f
endfor

" }}}
" {{{ ***DISABLED*** Testing
" let b:systemverilog_indent_ifdef_off
" }}} 
