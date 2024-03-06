function! AddToPathRecursive (mypath)
    let command = 'find ' .. a:mypath .. ' -type d | grep -v .git'
    let mylist  = systemlist(command)
    for path in mylist
        let &path = &path .. ',' .. path
        " echomsg path
        " echomsg &path
    endfor
    let split_path = split(&path, ',')
    let split_path = uniq(sort(split_path))
    let &path = ',' .. join(split_path, ",")
endfunction

