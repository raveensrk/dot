let mapleader = " "

map F <Plug>Sneak_F
map T <Plug>Sneak_T
map f <Plug>Sneak_f
map t <Plug>Sneak_t
nmap <leader>/ :BLines<CR>
nmap <leader><leader>i :PlugClean<CR>:PlugInstall<CR>
nmap <leader><leader>x yyo<cr># {{{<Esc>q:pIread ! <Esc><CR>o# }}}<Esc>
nmap <leader>= gg=G2<C-o>
nmap <leader>A ggVG
nmap <leader>E :e .<CR>
nmap <leader>W :wa<CR>
nmap <leader>X :%bd\|e#<cr>
nmap <leader>a 0
nmap <leader>c :tabnew \| wa \| make \| copen<cr>
nmap <leader>d :bd<cr>
nmap <leader>e $
nmap <leader>fR :lex eval('v:oldfiles') \| lopen<CR>
nmap <leader>fb :Buffers<CR>
nmap <leader>fc :e ~/.vimrc<CR>
nmap <leader>ff :Files<cr>
nmap <leader>fg :Rg<cr>
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>fp :let @* = expand("%:p")<cr>
nmap <leader>fr :History<CR>
nmap <leader>fw :Windows<CR>
nmap <leader>gf :e <cfile><CR>
nmap <leader>q :q<CR>
nmap <leader>r :RangerChooser<cr>
nmap <leader>s :%so<cr>
nmap <leader>tn :cnext<cr>
nmap <leader>tp :cprev<cr>
nmap <leader>tt :tabnew<cr>
nmap <leader>tw :set nowrap!<cr>
nmap <leader>w <C-w>
nmap <leader>o :copen<cr>
nmap <leader>n :cn<cr>
nmap <leader>N :cp<cr>
nmap <leader>x yyq:p<CR>
nmap <leader>y ggVGy2<C-o>
nmap <silent> <Leader>+ :vertical resize +5<CR>
nmap <silent> <Leader>- :vertical resize -5<CR>
nmap <silent> <leader> :WhichKey '<Space>'<CR>
nmap Y yg_
nmap ga <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)

command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences :vimgrep // **
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! RemoveDoubleSpaces :999%s/  / /g
command! SplitArguments :s/ --/ \\\r--/g
command! SplitPlusargs :s/ -p/ \\\r-p/g
