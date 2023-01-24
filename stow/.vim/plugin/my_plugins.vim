" Plugins {{{
call plug#begin('~/.vim/plugged')
Plug 'junegunn/goyo.vim'
Plug 'dhruvasagar/vim-table-mode'
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'wellle/tmux-complete.vim'
Plug 'chrisbra/NrrwRgn'
Plug '907th/vim-auto-save'
" " Track the engine.
" Plug 'SirVer/ultisnips'
" " Snippets are separated from the engine. Add this if you want them:
" Plug 'honza/vim-snippets'
" Plug 'git@github.com:junegunn/limelight.vim'
Plug 'rstacruz/vim-xtract'
" Plug 'preservim/nerdtree'
Plug 'mhinz/vim-startify'
Plug 'git@github.com:maxbrunsfeld/vim-yankstack'
Plug 'git@github.com:tpope/vim-sensible'
Plug 'git@github.com:junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'git@github.com:junegunn/fzf.vim'
Plug 'git@github.com:morhetz/gruvbox'
" Plug 'vim/killersheep'
Plug 'git@github.com:frazrepo/vim-rainbow'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" Plug 'ctrlpvim/ctrlp.vim'
Plug 'git@github.com:junegunn/vim-easy-align'
Plug 'git@github.com:easymotion/vim-easymotion'
Plug 'git@github.com:tomtom/tcomment_vim'
Plug 'git@github.com:tpope/vim-unimpaired'
Plug 'git@github.com:tpope/vim-surround'
Plug 'git@github.com:tpope/vim-repeat'
" Plug 'mattn/emmet-vim'
Plug 'git@github.com:junegunn/vim-easy-align'
Plug 'git@github.com:mg979/vim-visual-multi', {'branch': 'master'}
" mg979/vim-visual-multi
Plug 'git@github.com:airblade/vim-gitgutter'
" Plug 'terryma/vim-expand-region'
" Plug 'dense-analysis/ale'
" Plug 'tommcdo/vim-exchange'
" Plug 'svermeulen/vim-yoink'
Plug 'git@github.com:tpope/vim-fugitive'
" Plug 'xolox/vim-easytags'
" Plug 'xolox/vim-misc'
" Plug 'preservim/tagbar'
Plug 'git@github.com:mhinz/vim-signify'
Plug 'git@github.com:azabiong/vim-highlighter'
" Plug 'git@github.com:vim-syntastic/syntastic'
"Plug 'jceb/vim-orgmode'

" Plug 'godlygeek/tabular'
" Plug 'plasticboy/vim-markdown'
"
Plug 'git@github.com:tpope/vim-markdown'

Plug 'git@github.com:liuchengxu/vim-which-key'
" Plug 'xolox/vim-misc'
" Plug 'xolox/vim-session'

Plug 'git@github.com:tpope/vim-speeddating'
Plug 'git@github.com:yoshi1123/vim-linebox'

" On-demand lazy load
" Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
"
" " To register the descriptions when using the on-demand load feature,
" " use the autocmd hook to call which_key#register(), e.g., register for the
" Space key:
" " autocmd! User vim-which-key call which_key#register('<Space>',
" 'g:which_key_map')

Plug 'git@github.com:mechatroner/rainbow_csv'
" Plug 'yegappan/taglist'
" Plug 'fholgado/minibufexpl.vim'
Plug 'git@github.com:ervandew/supertab'
Plug 'git@github.com:ledger/vim-ledger'
Plug 'git@github.com:nathanaelkane/vim-indent-guides'

call plug#end()
"{{{1 Plugin configs

let g:table_mode_corner='|'
let g:deoplete#enable_at_startup = 1

let g:auto_save = 1  " enable AutoSave on Vim startup


" " Trigger configuration. You need to change this to something other than <tab>
" " if you use one of the following:
" " " - https://github.com/Valloric/YouCompleteMe
" " " - https://github.com/nvim-lua/completion-nvim
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" " If you want :UltiSnipsEdit to split your window.
" let g:UltiSnipsEditSplit="vertical"

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


set updatetime=100 " For gitgutter

" nmap <F8> :TagbarToggle<CR>

" let g:rainbow_active = 1
" let g:airline#extensions#tabline#enabled = 1

" Vim Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Vim Expand Region
" map K <Plug>(expand_region_expand)
" map J <Plug>(expand_region_shrink)

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
nnoremap <leader>/ :BLines<CR>

"}}}
" {{{ COLOR / THEME
colo gruvbox
" colo default
set background=dark
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
            " }}}
            " {{{1 NERDTree
            " "nnoremap <leader>n :NERDTreeFocus<CR>
            " "nnoremap <C-n> :NERDTree<CR>
            " "nnoremap <C-t> :NERDTreeToggle<CR>
            " "nnoremap <C-f> :NERDTreeFind<CR>
            " "" Exit Vim if NERDTree is the only window remaining in the only tab.
            \" autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
            "  Close the tab if NERDTree is the only window remaining in it.
            " "autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
            " "" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
            \" autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
            \"     \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
"  Open the existing NERDTree on each new tab.
" "autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif

" {{{ Limelight
" nmap <Leader>l <Plug>(Limelight)
" xmap <Leader>l <Plug>(Limelight)
"
" " Color name (:help cterm-colors) or ANSI code
" let g:limelight_conceal_ctermfg = 'gray'
" let g:limelight_conceal_ctermfg = 240
"
" " Color name (:help gui-colors) or RGB color
" let g:limelight_conceal_guifg = 'DarkGray'
" let g:limelight_conceal_guifg = '#777777'
"
" " Default: 0.5
" let g:limelight_default_coefficient = 0.7
"
" " Number of preceding/following paragraphs to include (default: 0)
" let g:limelight_paragraph_span = 1
"
" " Beginning/end of paragraph
" "   When there's no empty line between the paragraphs
" "   and each paragraph starts with indentation
" let g:limelight_bop = '^\s'
" let g:limelight_eop = '\ze\n^\s'
"
" " Highlighting priority (default: 10)
" "   Set it to -1 not to overrule hlsearch
" let g:limelight_priority = -1
