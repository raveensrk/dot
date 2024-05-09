" Just a small wrapper around vimgrep. I always wanted it to be more
" interactive. This seems to do the job.

set grepprg=RIPGREP_CONFIG_PATH=~/dot/config/ripgrep\ rg\ --no-heading\ --with-filename\ --column\ -g\ !tags\ -g\ !TAGS\ $*

function! FindGrep () abort
    " set wildoptions=pum,fuzzy,tagfile
    let dir=expand("%:p:h")
    " let ext="**.*"..expand("%:e")
    let pattern=input("Enter pattern to search: ", expand("<cword>"))
    let dir=input("Enter dir path to search: ", dir, "dir")
    " call chdir(dir)
    " let extension=input("Enter extension to search: ", ext)
    redraw!
    " let cmd =  "vimgrep! ".."/"..pattern.."/".." "..dir.."/**".."/"..extension
	" There is some bug here
    let cmd =  "grep! -e "..pattern.." "..dir
    redraw!
	echowindow cmd
    call histadd("cmd", cmd)
    execute 'cd ' .. dir
    silent! execute cmd
    copen
    " set wildoptions=fuzzy,tagfile
endfunction
command! FindGrep call FindGrep()
nmap <leader>fg :FindGrep<CR>

