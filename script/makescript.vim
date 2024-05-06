function! MakeScript() abort
	try
		let filename = input("Enter filename_with_extension: ")
		let path = input("Enter Path: ", "", "dir")
		let cmd=expand('e '..path.."/"..filename)
		echowindow cmd
		call histadd("cmd", cmd)
		execute cmd
	catch
		call popup_dialog("Not creating script...", #{time: 1000})
		call popup_clear()
		quit
	endtry
endfunction
command! MakeScript call MakeScript()
