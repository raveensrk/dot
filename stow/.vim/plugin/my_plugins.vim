" PLUG FUNCTION CALL {{{
call plug#begin('~/.vim/plugged')

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" Plug 'mattn/emmet-vim'
" Plug 'vim/killersheep'
Plug '907th/vim-auto-save'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'SidOfc/mkdx'
Plug 'SirVer/ultisnips'
Plug 'chamindra/marvim' " Named macros in vim
Plug 'chrisbra/Colorizer'
Plug 'chrisbra/NrrwRgn'
Plug 'dhruvasagar/vim-table-mode'
Plug 'git@github.com:airblade/vim-gitgutter'
Plug 'git@github.com:azabiong/vim-highlighter'
Plug 'git@github.com:easymotion/vim-easymotion'
Plug 'git@github.com:ervandew/supertab'
Plug 'git@github.com:frazrepo/vim-rainbow'
Plug 'git@github.com:junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'git@github.com:junegunn/fzf.vim'
Plug 'git@github.com:junegunn/limelight.vim'
Plug 'git@github.com:junegunn/vim-easy-align'
" Plug 'git@github.com:ledger/vim-ledger'
Plug 'git@github.com:liuchengxu/vim-which-key'
Plug 'git@github.com:mechatroner/rainbow_csv'
Plug 'git@github.com:mg979/vim-visual-multi', {'branch': 'master'}
Plug 'git@github.com:mhinz/vim-signify'
Plug 'git@github.com:morhetz/gruvbox'
Plug 'git@github.com:nathanaelkane/vim-indent-guides'
Plug 'git@github.com:tomtom/tcomment_vim'
Plug 'git@github.com:tpope/vim-fugitive'
Plug 'git@github.com:tpope/vim-markdown'
Plug 'git@github.com:tpope/vim-repeat'
Plug 'git@github.com:tpope/vim-sensible'
Plug 'git@github.com:tpope/vim-speeddating'
Plug 'git@github.com:tpope/vim-surround'
Plug 'git@github.com:tpope/vim-unimpaired'
Plug 'git@github.com:yoshi1123/vim-linebox'
Plug 'honza/vim-snippets'
Plug 'junegunn/vim-peekaboo'
Plug 'justinmk/vim-sneak'
Plug 'lfv89/vim-interestingwords'
Plug 'madox2/vim-ai'
Plug 'mhinz/vim-startify'
Plug 'mtth/scratch.vim'
Plug 'rstacruz/vim-xtract'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-vinegar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'wellle/tmux-complete.vim'

call plug#end()
" }}}
" INDENT GUIDES{{{
let g:indent_guides_enable_on_vim_startup = 1
"}}}
"{{{ ULTISNIPS
" Trigger configuration. You need to change this to something other than <tab> if you use one of the following:
" - https://github.com/Valloric/YouCompleteMe
" - https://github.com/nvim-lua/completion-nvim
let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsExpandTrigger="<c-e>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "my_snippets"]
"}}}
" {{{ VIM SNEAK 
let g:sneak#label = 1
" }}}
"{{{ TABLE MODE
let g:table_mode_corner='|'
"}}}
" DEOPLETE{{{
if has('python3')
  let g:deoplete#enable_at_startup = 1
endif
"}}}
" AUTOSAVE {{{
" let g:auto_save = 1  " enable AutoSave on Vim startup
"}}}
" LINEBOX{{{

let g:linebox_default_maps = 0
let g:linebox_marks = ["'a", "'b"]
let g:linebox_animation = 1

"}}}
"{{{ GIT GUTTER
set updatetime=100 " For gitgutter
"}}}
" RAINBOW{{{
" let g:rainbow_active = 1
"}}}
" AIRLINE{{{
let g:airline#extensions#tabline#enabled = 1
"}}}
" {{{ COLOR / THEME
colo gruvbox
" colo default
set background=dark
let g:gruvbox_contrast_dark="hard"
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
" }}}
