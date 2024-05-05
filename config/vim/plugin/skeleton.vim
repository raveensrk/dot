autocmd BufNewFile *.bash	0read $DOT/config/vim/skeleton/bash
autocmd BufNewFile *.sh		0read $DOT/config/vim/skeleton/bash
autocmd BufNewFile *.sv		0read $DOT/config/vim/skeleton/sv/main.sv
autocmd BufNewFile *.py 0read $DOT/config/vim/skeleton/python/python.py

function! SkeletonRead() abort
	let skeleton=input("Enter the skeleton file name: ", $DOT .. "/config/vim/skeleton/", "file")
	let cmd=expand('read ' .. skeleton)
	echowindow cmd
	call histadd("cmd", cmd)
	execute cmd
endfunction

command! SkeletonRead call SkeletonRead()
