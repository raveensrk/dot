" Just a small wrapper around vimgrep. I always wanted it to be more
" interactive. This seems to do the job.

set grepprg=RIPGREP_CONFIG_PATH=~/dot/config/ripgrep\ rg\ --no-heading\ --with-filename\ --column\ -g\ !tags\ -g\ !TAGS\ $*

function! FindGrep (pattern = "", extension="", path = "") abort
	" set wildoptions=pum,fuzzy,tagfile
	" let ext="**.*"..expand("%:e")
	echowindow "Pattern = "..a:pattern..": Path = "..a:path 
	if a:pattern==""
		let pattern=input("Enter pattern to search: ", expand("<cword>"))
	else
		let pattern=a:pattern
	endif

	if a:path==""
		let dir=expand("%:p:h")
		let dir=input("Enter dir path to search: ", dir, "dir")
	else
		let dir=a:path
	endif
	" call chdir(dir)
	" let extension=input("Enter extension to search: ", ext)
	redraw!
	" let cmd =  "vimgrep! ".."/"..pattern.."/".." "..dir.."/**".."/"..extension
	" There is some bug here
	if a:extension==""
		let cmd =  "grep! -e "..pattern.." "..dir
	else
		let cmd =  "grep! -e "..pattern.." "..dir.."/**/*."..a:extension
	endif
	redraw!
	echowindow cmd
	call histadd("cmd", cmd)
	execute 'cd ' .. dir
	silent! execute cmd
	copen
	" set wildoptions=fuzzy,tagfile
endfunction
command! -nargs=* FindGrep call FindGrep(<f-args>)
nmap <leader>fg :FindGrep<CR>

