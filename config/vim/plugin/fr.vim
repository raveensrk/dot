function! FR () abort
    let fr = readfile(expand('~/.viminfo'))
    let tmp = tempname()
    let f = []
    for line in v:oldfiles
        " echomsg line
        if match(line, '\~/Library/Mobile\ Documents/com\~apple\~CloudDocs')
            let line = substitute(line, '\~/Library/Mobile\ Documents/com\~apple\~CloudDocs', '\~/iCloud', '')
        endif
        let f = f + [line]
    endfor
    " let f = filter(f, 'v:val !~ "vim91"')
    " let f = filter(f, 'v:val !~ "\.vim"')
    " let f = filter(f, 'v:val !~ "/private/var/folders/"')
    call writefile(f, tmp)
    set errorformat+=%f
    cgetexpr copy(f)
    " execute 'edit' . tmp
endfunction

command! FR execute 'call FR() | copen'
nmap fr :FR<cr>/
