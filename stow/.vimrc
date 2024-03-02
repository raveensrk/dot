source $VIMRUNTIME/vimrc_example.vim

" HELP {{{
" Press <F1> for help
" K for help for word under cursor
" }}}
" BASICS {{{
set autoread
set mouse=a
set nocompatible
filetype plugin on
syntax on
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
set nowrap
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
"{{{ MARKDOWN
let g:markdown_folding = 1
noremap <2-LeftMouse> za
augroup markdown
    autocmd BufWinEnter *.md set nocursorline nocursorcolumn nonu nornu linebreak wrap
    autocmd BufWinEnter *.md syn match markdownError "\w\@<=\w\@="
    " hi link markdownError NONE 
augroup END
" let g:netrw_browsex_viewer="open"
function! OpenUrl()
    let l:url = expand('<cWORD>')
    execute '!echo "' . l:url . '" | urlview'
endfunction

nnoremap <silent> <leader>gx :call OpenUrl()<CR>
"}}}
"{{{ DELETE BUFFER AND FILE
"------------------------------
" Check if the buffer is empty
function! IsBufferEmpty() abort
    return line('$') == 1 && getline(1) == ''
endfunction

" Check if the buffer is the last buffer
function! IsLastBuffer() abort
    return buflisted(bufnr('%')) == 1 && bufnr('$') == bufnr('%')
endfunction

" Combine both checks
function! CheckEmptyAndLastBuffer() abort
    if IsBufferEmpty()
        echo "This buffer is empty."
    endif

    if IsLastBuffer()
        echo "This is the last buffer."
    endif
    return 1
endfunction

function! DeleteBufferAndFile()
    let save_confirm = &confirm
    set confirm
    let file_path = expand('%:p')
    echo file_path
    exe "bdel"
    execute "!clear"
    execute "!rm -iv '".file_path."'"
    let &confirm = save_confirm
    if CheckEmptyAndLastBuffer()
        exe "q"
    endif
endfunction

command! DeleteBufferAndFile call DeleteBufferAndFile()
"}}}
" VIEW NON COMMENTED LINES ONLY{{{
" ---------------------------------
function! ViewNonCommentedLines(comment_char)
    execute 'g/^[^' . a:comment_char . ']/p'
endfunction

command! -nargs=1 ViewNonCommentedLinesCommand call ViewNonCommentedLines(<q-args>)
"}}}
" END OF VIMRC TASKS {{{
" {{{ RESOURCE PLUGIN DIRECTORY
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
" }}}
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

" set cmdheight=2
" set smoothscroll
set clipboard^=unnamed
set complete+=t
set completeopt+=popup,preview
set makeef=/tmp/errorfile
set foldclose="all"
set showfulltag
" set showbreak=>>>\ 
set showmatch
set verbosefile=/tmp/verbosefile
set whichwrap+=<,>,[,]
set equalalways
set winfixheight
set winfixwidth
set isfname-==
set isfname-=,
autocmd FileType netrw cd %:p:h

func! QfOldFiles(info)
    " get information about a range of quickfix entries
    let items = getqflist({'id' : a:info.id, 'items' : 1}).items
    let l = []
    for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
        " use the simplified file name
        call add(l, fnamemodify(bufname(items[idx].bufnr), ':p:.'))
    endfor
    return l
endfunc

" create a quickfix list from v:oldfiles
nmap <leader>bH   :call setqflist([], ' ', {'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})<cr>:copen<cr>

" Hide unnamed buffers
autocmd BufLeave,BufEnter * if bufname('%') == '' && !&modified | setlocal bufhidden=hide | endif
" autocmd BufEnter * if bufname("%") | cd "%:h" | endif
" set autochdir

packadd cfilter
set switchbuf=uselast
autocmd! BufEnter *.log setlocal readonly 
autocmd! BufEnter *.log setlocal wrap
autocmd QuickFixCmdPost make set wrap
autocmd QuickFixCmdPost make set nowinfixheight nowinfixwidth
set viminfo+=r/opt/homebrew/
set viminfo+=r~/.vim/plugged
set exrc secure
" hi clear | hi CursorLine gui=underline cterm=underline
let mapleader = " "

" function! CD ()
"     let buffer_path = expand('%:h')
"     if buffer_path != ''
"         exec "cd " . buffer_path
"     endif
" endfunction
"
" command! CD call CD()
" autocmd BufEnter * CD

set tags=./tags,../tags
set path+=*
" set path+=**;~/ " This is awesome but find search takes too long
set path+=./;~/
" autocmd WinResized * wincmd =

autocmd WinNew * wincmd =
