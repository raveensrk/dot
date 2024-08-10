" nmap <Tab> mm==`m
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
nmap Y y$
" vmap <Tab> mm=`m
nmap <leader>= gg=G2<C-o>
nmap <leader>A ggVG
if has('clipboard')
    nmap <leader>y "+y
    xmap <leader>y "+y
    nmap <leader>p :norm o<cr>mm"+p`m
endif
nmap <leader>Y ggVGy2<C-o>
nmap <leader>t :set nowrap!<cr>
nmap <leader><leader>r :registers<CR>
vmap <leader>dd "_d
nmap <leader>0 "_dd
set nolist
nnoremap v <C-v>
nnoremap <C-v> v
set virtualedit=block
cnoremap <C-A>		<Home>
cnoremap <C-B>		<Left>
cnoremap <C-D>		<Del>
cnoremap <C-E>		<End>
cnoremap <C-F>		<Right>
cnoremap <C-N>		<Down>
cnoremap <C-P>		<Up>
cnoremap <Esc><C-B>	<S-Left>
cnoremap <Esc><C-F>	<S-Right>
nnoremap <S-UP> :move -2<cr>
nnoremap <S-DOWN> :move +1<cr>
nmap <leader>H :helpgrep 
command! TitleCase s/\v<(.)(\w*)/\u\1\L\2/g
command! SplitUpLine norm DO<Esc>p
command! SplitDownLine norm Do<Esc>p
nmap ,su :SplitUpLine<CR>
nmap ,sU :SplitDownLine<CR>

function! CommentAllMatchingLines (pattern) abort
	execute 'g/'..a:pattern..'/norm gcc'
endfunction
command! -nargs=1 CommentAllMatchingLines call CommentAllMatchingLines(<f-args>)
source ~/.vim/bundle/Damian-Conway-s-Vim-Setup/plugin/dragvisuals.vim
let g:DVB_TrimWS = 1
vmap  <expr>  <S-LEFT>   DVB_Drag('left')
vmap  <expr>  <S-RIGHT>  DVB_Drag('right')
vmap  <expr>  <S-DOWN>   DVB_Drag('down')
vmap  <expr>  <S-UP>     DVB_Drag('up')
vmap  <expr>  D        DVB_Duplicate()

" source ~/.vim/bundle/Damian-Conway-s-Vim-Setup/plugin/hlnext.vim
command AlignCSV %EasyAlign */,/
