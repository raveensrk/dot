if 0
    !git clone https://github.com/MattesGroeger/vim-bookmarks.git ~/.vim/bundle/vim-bookmarks
    !git clone https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup ~/.vim/bundle/Damian-Conway-s-Vim-Setup
    !git clone https://github.com/itchyny/lightline.vim.git ~/.vim/bundle/lightline.vim
    !git clone https://github.com/gcmt/taboo.vim.git ~/.vim/bundle/taboo.vim
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


let g:indent_guides_enable_on_vim_startup = 0
let g:sneak#label = 1
let g:gruvbox_contrast_dark="hard"
set noshowmode
set showcmd


let g:lightline = {
		\ 'colorscheme': 'gruvbox',
      \ 'active': {
      \ 'left': [ [ 'paste' ],
      \           [ 'readonly', 'filename', 'modified' ]
      \         ],
      \ 'right': [ ['bufnum'], 
      \             [ 'iswinfixbuf2' ], 
      \             [ 'lineinfo' ],
      \            [ 'percent' ]
      \          ] 
      \},
      \ 'inactive': {
      \ 'left': [ [ 'filename' ] ],
      \ 'right': [ ['bufnum'] ,
      \             [ 'iswinfixbuf2' ],
      \             [ 'lineinfo' ],
      \            [ 'percent' ] ] },
      \ 'component' : {
      \   'iswinfixbuf2': '%#ModifiedColor#%{IsWinFixBuf()}'
      \ }
      \}

function! IsWinFixBuf()
  if (&winfixbuf)
    echomsg "win fix buf"
    exe printf('hi ModifiedColor cterm=bold ctermfg=255 ctermbg=27')
    return " FIX"
  else
    echomsg "no win fix buf"
    exe printf('hi ModifiedColor cterm=bold ctermfg=245 ctermbg=245')
    return "    "
  endif
endfunction
" call lightline#init()
" call lightline#colorscheme()
" call lightline#update()
" call lightline#enable()

let g:gruvbox_contrast_dark='medium'
colo gruvbox
set background=dark
highlight CursorLine ctermbg=16
