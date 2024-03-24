function! AddHighlight() abort
    let pattern=input("Enter pattern: ", expand("<cword>"))
    let name=input("Enter a unique name for the highlight group: ")
    let fg=input("ctermfg: ")
    let bg=input("ctermbg: ")
    let hicmd="hi ".name." ctermfg=".fg." ctermbg=".bg
    let syncmd="match ".name." /".pattern."/"
    call histadd("cmd", hicmd)
    call histadd("cmd", syncmd)
    echowindow hicmd
    echowindow syncmd
    call execute(hicmd)
    call execute(syncmd)
    let perma=input("Save? Y/n: ", "")
    if perma=="Y"
        let file=input("Enter filename: ", expand("%:p:h:~:.")."/addhigh.vim", "file")
        execute "edit ".file
        execute "normal G"
        execute "normal p"
    endif
endfunction
command! AddHighlight call AddHighlight()
nmap ,a :AddHighlight<CR>
