
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
let g:loaded_appearance=1
