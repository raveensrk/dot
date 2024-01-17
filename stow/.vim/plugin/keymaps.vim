let mapleader = " "

" Keymaps
" -----------
map F <Plug>Sneak_F
map T <Plug>Sneak_T
map f <Plug>Sneak_f
map t <Plug>Sneak_t
nmap <leader>/ :BLines<CR>
nmap <leader><Down> :tabnext<cr>
nmap <leader><Left> :bp<CR>
nmap <leader><Right> :bn<CR>
nmap <leader><Up> :tabprevious<cr>
nmap <leader><leader><Down> <C-w><Down>
nmap <leader><leader><Left> <C-w><Left>
nmap <leader><leader><Right> <C-w><Right>
nmap <leader><leader><Up> <C-w><Up>
" nmap <leader><leader>B :call linebox#boxes#mbox()<cr>
" nmap <leader><leader>L :call linebox#lines#line(g:linebox_marks[0], g:linebox_marks[1])<cr>
" nmap <leader><leader>b :call linebox#boxes#box()<cr>
nmap <leader><leader>i :PlugClean<CR>:PlugInstall<CR>
nmap <leader><leader>x yyo<cr># {{{<Esc>q:pIread ! <Esc><CR>o# }}}<Esc>
nmap <leader>= gg=G2<C-o>
nmap <leader>A ggVG
nmap <leader>E :20Lexplore<CR>
nmap <leader>O <C-w>o
nmap <leader>a 0
nmap <leader>bb :Buffers<CR>
nmap <leader>bh :History<CR>
nmap <leader>bH :bro ol<CR>
nmap <leader>bk :bd \| vsp \| bp<cr>
nmap <leader>bd :bd<cr>
nmap <leader>bx :%bd\|e#<cr>
nmap <leader>e $
nmap <leader>ff :Files<cr>
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>fp :let @* = expand("%:p")<cr>
nmap <leader>gf :e <cfile><CR>
nmap <leader>i :e ~/.vimrc<CR>
nmap <leader>n :set nu!<cr>
nmap <leader>o <C-w><C-w>
nmap <leader>q :q<CR>
nmap <leader>r :RangerChooser<cr>
nmap <leader>s :%so<cr>
nmap <leader>t :set nowrap!<cr>
nmap <leader>v :vsp<cr>
nmap <leader>w :w<CR>
nmap <leader>x yyq:p<CR>
nmap <leader>y ggVGy2<C-o>
nmap <silent> <Leader>+ :vertical resize +5<CR>
nmap <silent> <Leader>- :vertical resize -5<CR>
nmap <silent> <leader> :WhichKey '<Space>'<CR>
nmap Y yg_
nmap ga <Plug>(EasyAlign)
" vmap <leader><leader>B :call linebox#boxes#mbox()<cr>
" vmap <leader><leader>b :call linebox#boxes#box()<cr>
xmap ga <Plug>(EasyAlign)

" Custom Commands
" ------------------

command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences :grep  * -r
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! RemoveDoubleSpaces :%s/  / /g
command! SplitArguments :s/ --/ \\\r--/g
command! SplitPlusargs :s/ -p/ \\\r-p/g

function! Grep(str, str2)
    echo a:str a:str2
    echo "vimgrep " .. a:str .. " " .. a:str2
    " execute  "vimgrep " .. "vim" .. " " .. "**"
    " execute  "vimgrep " .. a:str . " " .. a:str2
    execute  "vimgrep " .. a:str .. " " .. a:str2
    " copen
    " setlocal nowrap
    " execute 'vertical copen'
    execute 'copen'
    exe "norm \<cr>"
    exe "normal \<c-w>="
    setlocal nowrap
endfunction

command! Grep call Grep(<f-args>)

map <leader>n :cnext<cr>
map <leader>p :cprev<cr>
