function! SearchString() abort
	let cmd=expand('vim /'.expand("<cword>").'/ % | copen | wincmd J')
	echowindow cmd
	call histadd("cmd", cmd)
	execute cmd
endfunction
command! SearchString call SearchString()
