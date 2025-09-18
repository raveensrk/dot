function! LogOpenedFile()
    let l:file = expand('%:p')
    let l:logfile = expand('~/.vim_opened_files.log')

    " Read existing lines
    if filereadable(l:logfile)
        let l:lines = readfile(l:logfile)
    else
        let l:lines = []
    endif

    " Add only if not already present
    if index(l:lines, l:file) == -1
        call writefile(l:lines + [l:file], l:logfile)
    endif
endfunction

augroup LogUniqueOpenedFiles
    autocmd!
    autocmd BufReadPost * call LogOpenedFile()
augroup END



command! OpenLoggedFiles call s:OpenLoggedFiles()

function! s:OpenLoggedFiles()
    let logfile = expand('~/.vim_opened_files.log')
    if filereadable(logfile)
        let lines = readfile(logfile)
        let reversed_lines = reverse(lines)
        call setqflist([], ' ', {'title': 'Opened Files', 'lines': reversed_lines, 'efm': '%f'})
        copen
    else
        echo "Log file not found: " . logfile
    endif
endfunction

