nmap <Tab> mm==`m
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
nmap Y y$
vmap <Tab> mm=`m
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
vmap <leader>R. y:s+"++gc<Left><Left><Left>
vmap <leader>R% y:%s+"++gc<Left><Left><Left>
set nolist
nnoremap v <C-v>
nnoremap <C-v> v
set virtualedit=block
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
set laststatus=0
nnoremap <S-UP> :move -2<cr>
nnoremap <S-DOWN> :move +1<cr>
nmap <leader>H :helpgrep 
