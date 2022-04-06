if filereadable(expand("$MY_REPOS/tags"))
    set tags+=$MY_REPOS/tags
endif

function! GenerateTags()
    :!tmux split-window -dh ~/.scripts/,generate_tags.bash
endfunction
