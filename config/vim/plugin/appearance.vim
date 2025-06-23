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

colo gruvbox
set background=dark
let g:gruvbox_transparent_bg=1
let g:gruvbox_contrast_dark="hard"
let g:gruvbox_contrast_light="hard"

" https://github.com/morhetz/gruvbox/wiki/Configuration#ggruvbox_contrast_dark
