set laststatus=0
function! FG () abort
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
command! FG call FG()
" nmap <leader>fg :vimgrep // **<Left><Left><Left><Left>
nmap <leader>fg :FG<CR>
nmap <leader>H :helpgrep 
