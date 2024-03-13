function! InsertDate()
    let pick = input("Enter time in am or pm: ")
    let pick2 = system("date --date='" . pick . "'")
    execute 'normal i' . pick2
endfunction

command! InsertDate call InsertDate()
map <leader>id :InsertDate<cr>

