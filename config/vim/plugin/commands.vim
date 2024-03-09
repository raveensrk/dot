function! SnippetCreate ()
	let name=input("Enter name of snippet: ")
	execute ".w $DOT/config/vim/snippet/" . name . ".txt"
endfunction

function! FindReferences ()
	let word=input("Enter word or symbol: ")
	let dir=input("Enter directory path: ", "**", "dir")
	try
		execute "vimgrep /" . word . "/ " . dir . "/**"
	catch
		echoerr "Command Error..."
		return
	endtry
	copen
endfunction 

command! CD :cd %:p:h 
command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences call FindReferences()
command! LS  !pwd; ls -l
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! RemoveDoubleSpaces :%s/  / /gc
command! Scratch  split /tmp/scratch.vim
command! SnippetCreate call SnippetCreate()
command! SnippetList Files $DOT/config/vim/snippet
command! SplitArguments :s/ --/ \\\r--/g
command! GTags !universal-ctags -R . && echo "set tags+=$(realpath tags)" >> $HOME/script/tags.vim
