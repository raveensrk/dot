if 0
	!mkdir -p ~/.vim/autoload ~/.vim/bundle
	!curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	" !wget -k -nc https://tpo.pe/pathogen.vim -o ~/.vim/autoload/pathogen.vim
    !git clone https://github.com/MattesGroeger/vim-bookmarks.git ~/.vim/bundle/vim-bookmarks
    !git clone https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup ~/.vim/bundle/Damian-Conway-s-Vim-Setup
    !git clone https://github.com/itchyny/lightline.vim.git ~/.vim/bundle/lightline.vim
    !git clone https://github.com/gcmt/taboo.vim.git ~/.vim/bundle/taboo.vim
    !git clone https://github.com/airblade/vim-rooter.git ~/.vim/bundle/vim-rooter
    !git clone https://github.com/vim-scripts/YankRing.vim.git ~/dot/config/vim/bundle/YankRing
    !git clone git@github.com:tpope/vim-speeddating.git ~/dot/config/vim/bundle/vim-speeddating
    " Damian-Conway-s-Vim-Setup/
    " fzf.vim/
    " fzf/
    " gruvbox/
    " lightline.vim/
    " taboo.vim/
    " tcomment_vim/
    " vim-256noir/
    " vim-ai/
    " vim-bookmarks/
    " vim-easy-align/
    " vim-easymotion/
    " vim-eunuch/
    " vim-indent-guides/
    " vim-linebox/
    " vim-peekaboo/
    " vim-repeat/
    " vim-sensible/
    " vim-sneak/
    " vim-startify/
    " vim-surround/
    " vim-unimpaired/
    " vim-vinegar/
    " vim-which-key/
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

