" nmap lg :silent !gitui<CR>:silent redraw!<CR>
nmap lg :silent !lazygit<CR>:silent redraw!<CR>
command! GACP cd %:p:h | Git add . | Git commit -m "Bug fix" | Git push 
