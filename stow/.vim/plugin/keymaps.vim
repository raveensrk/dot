let mapleader = " "
" Editing{{{
nmap     <leader>= gg=G2<C-o>
nmap <leader>gf :e <cfile><CR>
nnoremap <leader>t :set nowrap!<cr>
" Select and copy shortcut
nnoremap <leader>a ggVG
nnoremap <leader>y ggVGy2<C-o>
nnoremap Y yg_
"}}}
"  File navigation{{{
nnoremap <leader>e :Ex<CR>
nnoremap <leader>r :RangerChooser<cr>
nmap <leader>ff :Files<cr>
"}}}
" Plugin{{{
nnoremap <leader>i :PlugClean<CR>:PlugInstall<CR>
"}}}
" Window{{{
nnoremap <silent> <Leader>+ :vertical resize +5<CR>
nnoremap <silent> <Leader>- :vertical resize -5<CR>
"}}}
" EXECUTION{{{
nnoremap <leader>s :%so<cr>
" Execute current line in Vim Ex mode
nnoremap <leader>x yyq:p<CR>
" Execute current line in bash and return the results few lines below within a
" fold
nnoremap <leader><leader>x yyo<cr># {{{<Esc>q:pIread ! <Esc><CR>o# }}}<Esc>
"}}}
" Buffers{{{
nnoremap <leader>n :set nu!<cr>
nnoremap <leader>fp :let @* = expand("%:p")<cr>
nnoremap <leader>fi :echo expand("%:p")<cr>
nnoremap <leader>/ :BLines<CR>
" Navigate previous and next buffers respectively
nnoremap <leader><Left> :bp<CR>
nnoremap <leader><Right> :bn<CR>
" Write quit shortcut
nnoremap <leader>w   :w<CR>
nnoremap <leader>q   :q<CR>
nnoremap <leader><up> :tabprevious<cr>
nnoremap <leader><down> :tabnext<cr>
nmap <leader>bx :%bd\|e#<cr>
nmap <leader>bb :Buffers<CR>
nmap <leader>bh :History<CR>
nmap <leader>d  :bd \| vsp \| bp<cr>
"}}}
" Custom Commands{{{
" -----------------
command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences :grep  * -r
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! RemoveDoubleSpaces :%s/  / /g
command! SplitArguments :s/ --/\r--/g
"}}}
