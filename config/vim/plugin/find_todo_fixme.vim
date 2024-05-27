function! FindTodoFixme(path = "") abort
	if a:path==""
		let dir=expand("%:p:h")
		let dir=input("Enter dir path to search: ", dir, "dir")
	else
		let dir=a:path
	endif

	let cmd='grep "todo\|fixme" '..dir..' | copen 9999'
	echowindow cmd
	call histadd("cmd", cmd)
	execute cmd
endfunction

command! FindTodoFixme call FindTodoFixme()
