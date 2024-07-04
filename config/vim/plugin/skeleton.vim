autocmd BufNewFile *.bash	0read $DOT/config/vim/skeleton/bash
autocmd BufNewFile *.sh		0read $DOT/config/vim/skeleton/bash
autocmd BufNewFile *.sv		0read $DOT/config/vim/skeleton/sv/main.sv
" autocmd BufNewFile *.py 0read $DOT/config/vim/skeleton/python/python.py
autocmd BufNewFile *.py 0read $DOT/config/vim/skeleton/python/test_template.py

function! SkeletonRead() abort
	let skeleton=input("Enter the skeleton file name: ", $DOT .. "/config/vim/skeleton/", "file")
	let cmd=expand('read ' .. skeleton)
	echowindow cmd
	call histadd("cmd", cmd)
	execute cmd
endfunction

command! SkeletonRead call SkeletonRead()

function! SkeletonCreate ()
	" Create a skeleton file from the current file
	let name=input("Enter name of Skeleton with extension: ")
	let filetype=input("Enter filetype of Skeleton: ", &filetype)
	call mkdir(expand("$DOT/config/vim/skeleton/".filetype), "p")
	let skeleton="$DOT/config/vim/skeleton/".filetype."/".name
	execute "write ".skeleton
	execute "tabnew ".skeleton
    let autocmd="autocmd BufNewFile *.".filetype." 0read ".skeleton
    echowindow "Appending autocommand to skeleton.vim..."
    echowindow autocmd
    let autocmdfile=expand("$DOT/config/vim/plugin/skeleton.vim")
    echowindow autocmdfile
    call writefile([autocmd], autocmdfile, "a")
	execute "tabnew ".autocmdfile
endfunction
command! SkeletonCreate call SkeletonCreate()
autocmd BufNewFile *.pl 0read $DOT/config/vim/skeleton/perl/skeleton.pl
