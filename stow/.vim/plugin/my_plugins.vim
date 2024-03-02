call plug#begin('~/.vim/plugged')

Plug 'git@github.com:junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'git@github.com:junegunn/fzf.vim'
Plug 'git@github.com:madox2/vim-ai.git'
Plug 'git@github.com:easymotion/vim-easymotion'
Plug 'git@github.com:junegunn/vim-easy-align'
Plug 'git@github.com:liuchengxu/vim-which-key'
Plug 'git@github.com:morhetz/gruvbox'
Plug 'git@github.com:nathanaelkane/vim-indent-guides'
Plug 'git@github.com:tomtom/tcomment_vim'
Plug 'git@github.com:tpope/vim-repeat'
Plug 'git@github.com:tpope/vim-sensible'
Plug 'git@github.com:tpope/vim-surround'
Plug 'git@github.com:tpope/vim-unimpaired'
Plug 'junegunn/vim-peekaboo'
Plug 'justinmk/vim-sneak'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-eunuch'

if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1


Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'wellle/tmux-complete.vim'

let g:tmuxcomplete#asyncomplete_source_options = {
            \ 'name':      'tmuxcomplete',
            \ 'whitelist': ['*'],
            \ 'config': {
            \     'splitmode':      'words',
            \     'filter_prefix':   1,
            \     'show_incomplete': 1,
            \     'sort_candidates': 0,
            \     'scrollback':      0,
            \     'truncate':        0
            \     }
            \ }

Plug 'wellle/context.vim'
let g:context_enabled = 1
let g:context_add_autocmds = 1
let g:context_max_height = 21
let g:context_max_per_indent = 5
let g:context_max_join_parts = 5
let g:context_ellipsis_char = '·'
let g:context_highlight_normal = 'Normal'
let g:context_highlight_border = 'Comment'
let g:context_highlight_tag    = 'Special'
let g:indent_guides_enable_on_vim_startup = 0
let g:sneak#label = 1
let g:gruvbox_contrast_dark="hard"

Plug 'itchyny/lightline.vim'
set noshowmode
let g:lightline = {
            \ 'component_function': {
            \   'fileformat': 'LightlineFileformat',
            \   'filetype': 'LightlineFiletype',
            \ },
            \ }

function! LightlineFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightlineFiletype()
    return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction
let g:lightline = {
            \ 'component': {
            \   'lineinfo': '%3l:%-2v%<',
            \ },
            \ }
call plug#end()

colo gruvbox
set background=dark
