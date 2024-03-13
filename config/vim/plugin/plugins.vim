if 0
    !curl -LSso ~/dot/config/vim/autoload/pathogen.vim                       https://tpo.pe/pathogen.vim
    !git  clone 'https://github.com/dense-analysis/ale'                      ~/dot/config/vim/bundle/ale
    !git  clone 'git@github.com:easymotion/vim-easymotion'                   ~/dot/config/vim/bundle/vim-easymotion
    !git  clone 'git@github.com:junegunn/vim-easy-align'                     ~/dot/config/vim/bundle/vim-easy-align
    !git  clone 'git@github.com:junegunn/vim-peekaboo.git'                   ~/dot/config/vim/bundle/vim-peekaboo
    !git  clone 'git@github.com:justinmk/vim-sneak.git'                      ~/dot/config/vim/bundle/vim-sneak
    !git  clone 'git@github.com:liuchengxu/vim-which-key'                    ~/dot/config/vim/bundle/vim-which-key
    !git  clone 'git@github.com:madox2/vim-ai.git'                           ~/dot/config/vim/bundle/vim-ai.git
    !git  clone 'git@github.com:mg979/vim-visual-multi'                      ~/dot/config/vim/bundle/vim-visual-multi
    !git  clone 'git@github.com:mhinz/vim-signify'                           ~/dot/config/vim/bundle/vim-signify
    !git  clone 'git@github.com:morhetz/gruvbox'                             ~/dot/config/vim/bundle/gruvbox
    !git  clone 'git@github.com:nathanaelkane/vim-indent-guides'             ~/dot/config/vim/bundle/vim-indent-guides
    !git  clone 'git@github.com:tomtom/tcomment_vim'                         ~/dot/config/vim/bundle/tcomment_vim
    !git  clone 'git@github.com:tpope/vim-repeat'                            ~/dot/config/vim/bundle/vim-repeat
    !git  clone 'git@github.com:tpope/vim-sensible'                          ~/dot/config/vim/bundle/vim-sensible
    !git  clone 'git@github.com:tpope/vim-speeddating.git'                   ~/dot/config/vim/bundle/vim-speeddating
    !git  clone 'git@github.com:tpope/vim-surround'                          ~/dot/config/vim/bundle/vim-surround
    !git  clone 'git@github.com:tpope/vim-unimpaired'                        ~/dot/config/vim/bundle/vim-unimpaired
    !git  clone 'git@github.com:tpope/vim-vinegar'                           ~/dot/config/vim/bundle/vim-vinegar
    !git  clone 'https://github.com/MattesGroeger/vim-bookmarks.git'         ~/dot/config/vim/bundle/vim-bookmarks
    !git  clone 'https://github.com/gcmt/taboo.vim.git'                      ~/dot/config/vim/bundle/taboo.vim
    !git  clone 'https://github.com/itchyny/lightline.vim.git'               ~/dot/config/vim/bundle/lightline.vim
    !git  clone 'https://github.com/mechatroner/rainbow_csv'                 ~/dot/config/vim/bundle/rainbow_csv
    !git  clone 'https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup' ~/dot/config/vim/bundle/Damian-Conway-s-Vim-Setup
    !git  clone 'https://github.com/vim-scripts/YankRing.vim.git'            ~/dot/config/vim/bundle/YankRing
    !git  clone 'git@github.com:ctrlpvim/ctrlp.vim.git'                      ~/dot/config/vim/bundle/ctrlp
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
" colo gruvbox
" let g:gruvbox_contrast_dark="hard"
" set background=dark
