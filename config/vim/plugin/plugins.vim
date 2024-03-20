if 0
    !git clone https://github.com/MarcWeber/vim-addon-qf-layout.git         ~/.vim/bundle/vim-addon-qf-layout
    !git clone https://github.com/chrisbra/Colorizer                        ~/.vim/bundle/Colorizer
    !git clone 'git@github.com:pelodelfuego/vim-swoop.git'                  ~/.vim/bundle/vim-swoop
    !curl -LSso ~/dot/config/vim/autoload/pathogen.vim                       https://tpo.pe/pathogen.vim
    !git  clone 'https://github.com/dense-analysis/ale'                      ~/.vim/bundle/ale
    !git  clone 'git@github.com:easymotion/vim-easymotion'                   ~/.vim/bundle/vim-easymotion
    " !~/.vim/bundle/fzf/install --all
    !git  clone 'git@github.com:junegunn/fzf'                                ~/.vim/bundle/fzf
    !git  clone 'git@github.com:junegunn/fzf.vim'                            ~/.vim/bundle/fzf.vim
    !git  clone 'git@github.com:junegunn/vim-easy-align'                     ~/.vim/bundle/vim-easy-align
    !git  clone 'git@github.com:junegunn/vim-peekaboo.git'                   ~/.vim/bundle/vim-peekaboo
    !git  clone 'git@github.com:justinmk/vim-sneak.git'                      ~/.vim/bundle/vim-sneak
    !git  clone 'git@github.com:liuchengxu/vim-which-key'                    ~/.vim/bundle/vim-which-key
    !git  clone 'git@github.com:madox2/vim-ai.git'                           ~/.vim/bundle/vim-ai.git
    !git  clone 'git@github.com:mg979/vim-visual-multi'                      ~/.vim/bundle/vim-visual-multi
    !git  clone 'git@github.com:mhinz/vim-signify'                           ~/.vim/bundle/vim-signify
    !git  clone 'git@github.com:morhetz/gruvbox'                             ~/.vim/bundle/gruvbox
    !git  clone 'git@github.com:nathanaelkane/vim-indent-guides'             ~/.vim/bundle/vim-indent-guides
    !git  clone 'git@github.com:tomtom/tcomment_vim'                         ~/.vim/bundle/tcomment_vim
    !git  clone 'git@github.com:tpope/vim-repeat'                            ~/.vim/bundle/vim-repeat
    !git  clone 'git@github.com:tpope/vim-sensible'                          ~/.vim/bundle/vim-sensible
    !git  clone 'git@github.com:tpope/vim-speeddating.git'                   ~/.vim/bundle/vim-speeddating
    !git  clone 'git@github.com:tpope/vim-surround'                          ~/.vim/bundle/vim-surround
    !git  clone 'git@github.com:tpope/vim-unimpaired'                        ~/.vim/bundle/vim-unimpaired
    !git  clone 'git@github.com:tpope/vim-vinegar'                           ~/.vim/bundle/vim-vinegar
    !git  clone 'git@github.com:tpope/vim-eunuch'                           ~/.vim/bundle/vim-eunuch
    !git  clone 'git@github.com:tpope/vim-fugitive'                           ~/.vim/bundle/vim-fugitive
    !git  clone 'https://github.com/MattesGroeger/vim-bookmarks.git'         ~/.vim/bundle/vim-bookmarks
    !git  clone 'https://github.com/gcmt/taboo.vim.git'                      ~/.vim/bundle/taboo.vim
    !git  clone 'https://github.com/itchyny/lightline.vim.git'               ~/.vim/bundle/lightline.vim
    !git  clone 'https://github.com/mechatroner/rainbow_csv'                 ~/.vim/bundle/rainbow_csv
    !git  clone 'https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup' ~/.vim/bundle/Damian-Conway-s-Vim-Setup
    !git  clone 'https://github.com/vim-scripts/YankRing.vim.git'            ~/.vim/bundle/YankRing
    !git clone 'git@github.com:preservim/tagbar.git'                         ~/.vim/bundle/tagbar
    !git  clone 'git@github.com:ctrlpvim/ctrlp.vim.git'                      ~/.vim/bundle/ctrlp
endif

let g:bookmark_no_default_key_mappings = 1

nmap <Leader>mm <Plug>BookmarkToggle
nmap <Leader>mi <Plug>BookmarkAnnotate
nmap <Leader>ma <Plug>BookmarkShowAll
nmap <Leader>mn <Plug>BookmarkNext
nmap <Leader>mp <Plug>BookmarkPrev
nmap <Leader>mc <Plug>BookmarkClear
nmap <Leader>mx <Plug>BookmarkClearAll
nmap <Leader>mu <Plug>BookmarkMoveUp
nmap <Leader>md <Plug>BookmarkMoveDown
nmap <Leader>mg <Plug>BookmarkMoveToLine

let g:sneak#label = 1
set showmode
set showcmd
let g:colorizer_auto_color = 1
let g:colorizer_conceal_cursor_mode='nvc'

let g:yankring_history_dir = expand('~/dot/config/vim')
let g:yankring_history_file = expand('yankring_history')
let g:ale_virtualtext_cursor=0

source ~/.vim/bundle/Damian-Conway-s-Vim-Setup/plugin/dragvisuals.vim                          
let g:DVB_TrimWS = 1                                    
vmap  <expr>  <S-LEFT>   DVB_Drag('left')               
vmap  <expr>  <S-RIGHT>  DVB_Drag('right')              
vmap  <expr>  <S-DOWN>   DVB_Drag('down')               
vmap  <expr>  <S-UP>     DVB_Drag('up')                 

" This declares the defaults, so just add the keys to .vimrc you want to change
let g:vim_addon_qf_layout = {}
let g:vim_addon_qf_layout.quickfix_formatters = [ 'NOP', 'vim_addon_qf_layout#DefaultFormatter', 'vim_addon_qf_layout#FormatterNoFilename', 'vim_addon_qf_layout#Reset' ]
let g:vim_addon_qf_layout.lhs_cycle = '<buffer> \v'
let g:vim_addon_qf_layout.file_name_align_max_width = 60

" Optionally you can define your own mappings like this:
noremap \no_filenames call vim_addon_qf_layout#ReformatWith('vim_addon_qf_layout#FormatterNoFilename')<cr>
