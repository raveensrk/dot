function! B2D() abort
	let save_cursor = getcurpos()
	let cmd='bc -e "ibase=2;'.expand("<cword>").'"'
	echowindow cmd
	call histadd("cmd", "!".cmd)
	silent let val=system(cmd)->split("\n", 1)
	echowindow val[0]
	execute "s/".expand("<cword>")."/".val[0]."/g"
	redraw!
	call setpos('.', save_cursor)
endfunction

command! B2D call B2D()
command! Binary2Decimal call B2D()

