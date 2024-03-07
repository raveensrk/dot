command! CD :cd %:p:h 
command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences lvimgrep // ** | lopen
command! LS  !pwd; ls -l
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! RemoveDoubleSpaces :%s/  / /gc
command! Scratch  split /tmp/scratch.vim
command! SnippetCreate .w >> ~/.vim/quick_snippet.txt
command! SnippetList tabnew ~/.vim/quick_snippet.txt
command! SplitArguments :s/ --/ \\\r--/g
command! Tags !universal-ctags -R . && echo "set tags+=$(realpath tags)" >> ~/.my_vim_configs/tags.vim
