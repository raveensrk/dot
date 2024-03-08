" Location and Quickfix list{{{
nmap ,,, :lopen<cr>
nmap ,,n :lnext<cr>,,
nmap ,,p :lprevious<cr>,,
nmap ,n :cnext<cr>,
nmap ,p :cprevious<cr>,
nmap ,c :copen<cr>
"}}}
" Fix annoyances{{{
imap <TAB> <C-n>
imap <S-Tab> <C-p>
nnoremap Q  q
nnoremap q <NOP>
"}}}
"Terminal{{{
nnoremap ; :
nnoremap : :
nnoremap <leader>; :term 
nmap ,cd :cd %:h<CR>
"}}}
 " Searching{{{
nmap <leader>h :help 
nmap <leader>/ :Lines<CR>
nmap <leader>? :BLines<CR>
"}}}
" Tabs and buffers{{{
nmap <leader>. :e .<CR>
nmap <leader><down> :tabnext<cr>
nmap <leader><leader><up> :lprevious<cr>
nmap <leader>K :%bd\|e#<cr>
nmap <leader>D :bd!<cr>
nmap <leader><leader><down> :lnext<cr>
nmap <leader><left> :bp<cr>
nmap <leader><right> :bn<cr>
nmap <leader><up> :tabprev<cr>
nmap <leader>F :set winfixbuf!<cr>
"}}}
" Editing{{{
nmap <Tab> mm==`m
vmap <Tab> mm=`m
nmap <leader>R :s//"/g
nmap <leader>= gg=G2<C-o>
nmap <leader>A ggVG
nmap <leader>G :lvim /"/ **<CR>lopen<CR>lfirst<CR>
"}}}
 " Copy and paste{{{
if has('clipboard')
    nmap <leader>y "+y
    xmap <leader>y "+y
else
    nmap <leader>y :.w! ~/.vim_clip<cr>:silent !xclip ~/.vim_clip<cr>:redraw!<cr>

    xmap <leader>y :w! ~/.vim_clip<cr>:silent !xclip ~/.vim_clip<cr>:redraw!<cr>
endif
nmap <leader>p :norm o<cr>mm"+p`m
nmap <leader>Y ggVGy2<C-o>
"}}}
nmap <leader>` :Scratch<cr>
nmap <leader>a 0
nmap <leader>c :wa \| silent make! \| redraw! \| copen \| clast<cr>
nmap <leader>d :bd<cr>
nmap <leader>e $
nmap <leader>fB :redir >> ~/bookmarks \| echo expand("%:p") . ':' . getpos(".")[1] \| echo expand("%:h") \| redir END \| tabnew ~/bookmarks \| sort \| w \| execute '%!uniq' \| w<cr>
nmap <leader>fb :b 
nmap <leader>fc :e ~/.vimrc<CR>
nmap <leader>fF :Files<cr>
nmap <leader>ff :find 
nmap <leader>fg :Rg<cr>
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>fp :let @+ = expand("%:p")<cr>
nmap <leader>fr :History<CR>
nmap <leader>fw :Windows<CR>
nmap <leader>gf :e <cfile><CR>
nmap <leader>q :q<CR>
nmap <leader>r :RangerChooser<cr>
nmap <leader>s :so<cr>
nmap <leader>t :set nowrap!<cr>
nmap <leader>w :w<CR>
nmap <leader>x :.so<CR>
xmap <leader>x :so<CR>
nmap <leader>X :.!bash<CR>redraw!<CR>
xmap <leader>X :!bash<CR>redraw!<CR>
nmap <leader>z <C-w>
nmap <leader>Z :windo set scrollbind!<CR>
nmap <leader>T :tab split<CR>
nmap <leader>S :tab split<CR>:term<cr>

nmap Y yg_
nmap _ :vertical resize -5<CR>
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
vmap <leader>dd "_d
" nmap <Right> <nop>
" nmap <Up>   <nop>
" nmap <Down> <nop>
" nmap <Left> <nop>
set ttimeoutlen=9000 ttimeout timeout timeoutlen=9000
nmap <leader>n h<leader>
nmap <leader>e j<leader>
nmap <leader>i k<leader>
nmap <leader>o l<leader>
