command! CD :cd %:p:h 
command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences call FindReferences()
command! LS  !pwd; ls -l
" TODO: Make this accept range and make this a function
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! Scratch  split /tmp/scratch.vim
command! SplitArguments :s/ --/ \\\r--/g
command! -range RemoveDoubleSpaces <line1>,<line2>s/  / /g
command! ShellCheckDisable s/\(.*\)/# shellcheck disable=0000,0000\r\1/g
