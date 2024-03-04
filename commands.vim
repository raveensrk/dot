" command! -nargs=* Help tab help <args>
" command! -nargs=+ Helpgrep tab helpgrep <args>
command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences :cd "%:h" \| echo hello
command! FindReferences :cd %:h | lvimgrep // ** | lopen
command! Pin :set modified!
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! RemoveDoubleSpaces :%s/  / /gc
command! SplitArguments :s/ --/ \\\r--/g
command! SplitPlusargs :s/ -p/ \\\r-p/g
command! PlugSync :exec "PlugClean | PlugUpgrade | sleep 2 |  PlugUpdate | sleep 10 | PlugInstall"
command! SnippetList tabnew ~/.vim/quick_snippet.txt
command! SnippetCreate .w >> ~/.vim/quick_snippet.txt
command! Scratch split /tmp/scratch.vim
