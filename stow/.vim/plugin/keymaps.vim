" autocmd FileType netrw nmap <buffer> <nowait> OC   <cr>
" autocmd FileType netrw nmap <buffer> <nowait> OD    - 
" nmap <silent><leader> :WhichKey '<Space>'<CR>
map F <Plug>Sneak_F
map T <Plug>Sneak_T
map f <Plug>Sneak_f
map t <Plug>Sneak_t
nmap + :vertical resize +5<CR>
nmap ,<down> :cn<cr>
nmap ,<up> :cp<cr>
nmap ,cd :cd %:h<CR>
nmap <leader>. :e .<CR>
nmap <leader>/ :Lines<CR>
nmap <leader>? :BLines<CR>
nmap <leader><down> :tabnext<cr>
nmap <leader><leader><down> :ln<cr>
nmap <leader><leader><up> :lp<cr>
nmap <leader><left> :bp<cr>
nmap <leader><right> :bn<cr>
nmap <leader><up> :tabprev<cr>
nmap <leader>= gg=G2<C-o>
nmap <leader>A ggVG
nmap <leader>D :bd!<cr>
nmap <leader>G :lvim /"/ **<CR>lopen<CR>lfirst<CR>
nmap <leader>R :s//"/g
nmap <leader>X :%bd\|e#<cr>
nmap <leader>Y :.w! ~/.vim_clip<cr>!xclip ~/.vim_clip<cr>
nmap <leader>` :Scratch<cr>
nmap <leader>a 0
nmap <leader>c :wa \| silent lmake! \| redraw! \| lopen \| llast \| wincmd p<cr>
nmap <leader>d :bd<cr>
nmap <leader>e $
nmap <leader>fB :redir >> ~/bookmarks \| echo expand("%:p") . ':' . getpos(".")[1] \| echo expand("%:h") \| redir END \| tabnew ~/bookmarks \| sort \| w \| execute '%!uniq' \| w<cr>
nmap <leader>fb :Buffers<CR>
nmap <leader>fc :e ~/.vimrc<CR>
nmap <leader>ff :Files<cr>
nmap <leader>fg :Rg<cr>
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>fp :let @* = expand("%:p")<cr>
nmap <leader>fr :History<CR>
nmap <leader>fw :Windows<CR>
nmap <leader>gf :e <cfile><CR>
nmap <leader>n :ln<cr>
nmap <leader>p :lp<cr>
nmap <leader>q :q<CR>
nmap <leader>r :RangerChooser<cr>
nmap <leader>s :so<cr>
nmap <leader>t :set nowrap!<cr>
nmap <leader>w :wa<CR>
nmap <leader>x yyq:p<CR>
nmap <leader>y ggVGy2<C-o>
nmap Y yg_
nmap _ :vertical resize -5<CR>
nmap ga <Plug>(EasyAlign)
vmap <leader>Y :w! ~/.vim_clip<cr>!xclip ~/.vim_clip<cr>
xmap ga <Plug>(EasyAlign)
vmap <leader>dd "_d
" nmap <leader><Right> <C-w>l<leader>
" nmap <leader><Up> <C-w>k<leader>
" nmap <leader><Down> <C-w>j<leader>
" nmap <leader><Left> <C-w>h<leader>
" set ttimeoutlen=3000 ttimeout timeout timeoutlen=1000
