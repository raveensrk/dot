
if exists("g:loaded_appearance") 
	finish
endif

function! TitleString () abort
	return "VIM: "..&filetype..": "
endfunction

set title titlestring=%{TitleString()}%t titlelen=70
set showcmd
set showmode
set showtabline=1
set hidden
nnoremap <C-N> :bnext<CR>
nnoremap <C-P> :bprev<CR>
let g:loaded_appearance=1
