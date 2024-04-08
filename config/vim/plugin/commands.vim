

function! SkeletonCreate ()
	let name=input("Enter name of Skeleton: ")
	let filetype=input("Enter filetype of Skeleton: ", expand("%:e"))
	call mkdir(expand("$DOT/config/vim/skeleton/".filetype), "p")
	let skeleton="$DOT/config/vim/skeleton/".filetype."/".name.".".filetype
	execute "write ".skeleton
	execute "tabnew ".skeleton
    let autocmd="autocmd BufNewFile *.".filetype." 0read ".skeleton
    echowindow "Appending autocommand to skeleton.vim..."
    echowindow autocmd
    let autocmdfile=expand("$DOT/config/vim/plugin/skeleton.vim")
    echowindow autocmdfile
    call writefile([autocmd], autocmdfile, "a")
	execute "tabnew ".autocmdfile
endfunction
command! SkeletonCreate call SkeletonCreate()

command! CD :cd %:p:h 
command! Date -1read !date -I
command! DiffFold :set diffopt=filler,context:0
command! FindReferences call FindReferences()
command! LS  !pwd; ls -l
command! RefactorVariable :norm mzviwxOvar="<esc>pa"<esc>`zi"$var"<esc>
command! RemoveDoubleSpaces :%s/  / /gc
command! Scratch  split /tmp/scratch.vim
command! SplitArguments :s/ --/ \\\r--/g
