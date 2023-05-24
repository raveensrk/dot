let mapleader = " "
" imap nnn <Esc>
" This will create a file under cursor
nmap <leader>gf :e <cfile><CR>
" Find all reference of the string under cursor
nnoremap <leader>ref :grep  * -r<CR>
nmap     <leader>= gg=G2<C-o>
nnoremap Y yg_
nmap     <leader>b :Buffers<CR>
nnoremap <leader>n :set nu!<cr>
nnoremap <leader>fp :let @* = expand("%:p")<cr>
nnoremap <leader>ref :grep  * -r<CR>
nnoremap <leader>s :so %<cr>
nnoremap <leader>t :set nowrap!<cr>
nnoremap Y yg_

"noremap <Up> <NOP>
"noremap <Down> <NOP>
"noremap <Left> <NOP>
"noremap <Right> <NOP>

" Browse recent files
nnoremap <leader>h :History<CR>

" Navigate previous and next buffers respectively
nnoremap <leader><Left> :bp<CR>
nnoremap <leader><Right> :bn<CR>

" Write quit shortcut FINALLY!!!!!!!!!!!!!!
" -----------------------------------------------
nnoremap <leader>w   :w<CR>
nnoremap <leader>wq  :wq<CR>
nnoremap <leader>wqa :wqa<CR>
nnoremap <leader>q   :q<CR>
nnoremap <leader>qq  :q!<CR>
nnoremap <leader>qa  :qa<CR>
nnoremap <leader>qqa :qa!<CR>

nnoremap <leader>a ggVG
nnoremap <leader>y mmggVGy'm

" Other time savers
" -------------------------------
nnoremap <leader>dm  :set diffopt=filler,context:0<CR>
nnoremap <leader>e   :Ex<CR>jj
nnoremap <leader>pi :PlugClean<CR>:PlugInstall<CR>
nnoremap <silent> <Leader>+ :vertical resize +5<CR>
nnoremap <silent> <Leader>- :vertical resize -5<CR>

" " Move blocks on lines in visual mode
" vnoremap <Up>   :move -2<CR>gv=gv
" vnoremap <Down> :move +2<CR>gv=gv
"
" " Move single lines in normal mode
" nnoremap <Up>   :move -2<CR>
" nnoremap <Down> :move +1<CR>

" TODO Move vertial lines left or right in visual mode

nnoremap <leader>ac :s/ --/\r--/g<CR>

nnoremap <leader><tab> za

" Execute current line in Vim Ex mode
nnoremap <leader>x yyq:p<CR>

" Execute current line in bash and return the results few lines below within a
" fold
nnoremap <leader><leader>x yyo<cr># {{{<Esc>q:pIread ! <Esc><CR>o# }}}<Esc>
nnoremap <leader>r :RangerChooser<cr>

" Locaction list 
nnoremap <leader>ln :lnext<cr>
nnoremap <leader>lp :lprevious<cr>

" Align data set / make table
vnoremap <leader>align !column --table -s <input_seperator> -o <output_seperator>

" Date
nnoremap <leader>date :-1read !date +\%Y-\%m-\%d-\%H-\%M-\%S<cr>
