function! SnippetCreate (start,end)
	let name=input("Enter name of snippet: ")
	let filetype=input("Enter filetype of snippet: ")
	let extension=input("Enter extension of snippet: ", ".txt")
	let dir = $DOT .. "/config/vim/snippet/" .. filetype
	call mkdir(dir, 'p')
	let cmd = a:start.",".a:end."w $DOT/config/vim/snippet/".filetype."/".name.extension
	call histadd("cmd", cmd)
    echowindow cmd
	execute cmd
endfunction
command! -range SnippetCreate call SnippetCreate(<line1>,<line2>)
command! SnippetList Files $DOT/config/vim/snippet
nmap ,sr :SnippetRead<CR>
nmap ,sc :SnippetCreate<CR>
xmap ,sc :SnippetCreate<CR>

function! SnippetRead ()
	let filetype=&filetype
	let dir = $DOT .. "/config/vim/snippet/" .. filetype
	let name=input("Enter name of snippet: ", dir, "file")
	let cmd = "read "..name
	call histadd("cmd", cmd)
    echowindow cmd
	execute cmd
endfunction

command! SnippetRead call SnippetRead()
