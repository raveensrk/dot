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
set list
nnoremap v <C-v>
nnoremap <C-v> v
