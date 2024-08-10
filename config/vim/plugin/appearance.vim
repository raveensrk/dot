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
highlight TabLineSel ctermbg=16 ctermfg=255
highlight TabLineFill ctermbg=235 ctermfg=22
command! Colors term colors2

let g:loaded_appearance=1
