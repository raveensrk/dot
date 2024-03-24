" Just a small wrapper around vimgrep. I always wanted it to be more
" interactive just like emacs find-grep. This seems to do the job.

function! FindGrep () abort
    set wildoptions=pum,fuzzy,tagfile
    let dir=expand("%:p:h").."/**"
    let ext="**."..expand("%:e")
    let pattern=input("Enter pattern to search: ", expand("<cword>"))
    let dir=input("Enter dir path to search: ", dir, "dir")
    let extension=input("Enter extension to search: ", ext)
    redraw!
    let cmd =  "vimgrep " .. "/" .. pattern .. "/"  .. " " .. dir .. "/" .. extension
    call histadd("cmd", cmd)
    execute cmd
    echowindow cmd
    set wildoptions=fuzzy,tagfile
endfunction
command! FindGrep call FindGrep()
nmap <leader>fg :FindGrep<CR>
