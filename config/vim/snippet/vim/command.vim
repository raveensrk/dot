function! MakeScript() abort
	let filename = input("Enter filename_with_extension: ", "", "file")
	let path = input("Enter Path: ", "", "dir")
	let cmd=expand('e '..path.."/"..filename)
	echowindow cmd
	call histadd("cmd", cmd)
	execute cmd
endfunction
command! MakeScript call MakeScript()
