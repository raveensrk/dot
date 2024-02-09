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
" set hidden
set backspace=indent,eol,start
set encoding=utf-8
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
set splitbelow splitright
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
" set listchars=nbsp:_,tab:>-,trail:~,extends:>,precedes:<,eol:$
" set list
" }}}
" FOLDING AND WRAPPING {{{
set foldmethod=marker
" }}}
" {{{ NUMBERING
" set nonumber norelativenumber
set number 
" set relativenumber
" }}}
" {{{ INTERFACE
set nowrap
set linebreak
set cursorline
set cursorcolumn
set hlsearch
set ruler
" set columns=80
" set colorcolumn=80
" highlight ColorColumn ctermbg=0 guibg=lightgrey
" set wildmode=longest,list,full
set wildmenu
set wildoptions=pum
" These 2 settings will force the cursor line to always be at the center of
" the screen
set scrolloff=999
set sidescrolloff=999

" set virtualedit=all
" set textwidth=0 wrapmargin=0
" }}}
" {{{ BACKUPS AND UNDO
set noswapfile
set backup writebackup
set undofile
set undodir=~/.vim/undo
set backupdir=~/.vim/backup
" }}}
" {{{ PATH
set path+=**
set autochdir
" set noautochdir " This will change your pwd to current file
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
"}}}
" CTAGS {{{
set tags=tags
" }}}
"{{{ CLIPBOARD
vmap <silent> +y :w! ~/.vim_clip<cr>
nmap <silent> +p :read ~/.vim_clip<cr>

set clipboard=unnamed
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
" ↓ TESTING ↓ {{{
let g:netrw_dirhistmax=1000

" Emacs style commandline editing
" start of line
cnoremap <C-A>		<Home>
" back one character
cnoremap <C-B>		<Left>
" delete character under cursor
cnoremap <C-D>		<Del>
" end of line
cnoremap <C-E>		<End>
" forward one character
cnoremap <C-F>		<Right>
" recall newer command-line
cnoremap <C-N>		<Down>
" recall previous (older) command-line
cnoremap <C-P>		<Up>
" back one word
cnoremap <Esc><C-B>	<S-Left>
" forward one word
cnoremap <Esc><C-F>	<S-Right>
map ;b   GoZ<Esc>:g/^$/.,/./-j<CR>Gdd
map ;n   GoZ<Esc>:g/^[ <Tab>]*$/.,/[^ <Tab>]/-j<CR>Gdd
" }}}
