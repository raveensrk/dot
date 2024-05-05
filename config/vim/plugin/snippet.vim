command! SnippetRead call fzf#run({'dir': '~/dot/config/vim/snippet', 'source': 'find . -type f', 'sink': 'read'})
inoremap <expr> <c-x>s fzf#vim#complete({'dir': '~/dot/config/vim/snippet', 'source': 'find . -type f', 'reducer': { lines -> join(readfile(lines[0]))}})
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
