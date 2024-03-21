set laststatus=0
function! FG () abort
    set wildoptions=pum,fuzzy,tagfile
    let dir=input("Enter dir path to search: ", "**", "dir")
    let extension=input("Enter extension to search: ", "**.*")
    let pattern=input("Enter pattern to search: ", ".")
    redraw!
    let cmd =  "vimgrep " .. "/" .. pattern .. "/"  .. " " .. dir .. "/" .. extension
    execute cmd
    echomsg cmd
    set wildoptions=fuzzy,tagfile
endfunction
command! FG call FG()
" nmap <leader>fg :vimgrep // **<Left><Left><Left><Left>
nmap <leader>fg :FG<CR>
