if 0
    git clone https://github.com/MattesGroeger/vim-bookmarks.git ~/.vim/bundle/vim-bookmarks
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


let g:indent_guides_enable_on_vim_startup = 1
let g:sneak#label = 1
let g:gruvbox_contrast_dark="hard"
set noshowmode
let g:lightline = {
            \ 'component': {
            \   'lineinfo': '%3l:%-2v%<',
            \ }
            \ }


colo gruvbox
set background=dark

