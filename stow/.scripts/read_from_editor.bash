#!/bin/bash

source ~/.bash_prompt 

main () {
    local file=~/.tmp/tmp_read_from_editor.txt
    mkdir ~/.tmp
    touch $file
    $EDITOR $file
    blue
    cat $file
    nc
    if bash ask_user.bash -m "use this text as input"; then
        green
        echo "Using the following text as input:"
        cat $file
        nc
    else
        red
        echo "Not Using the following text as input. Exitting!:"
        cat $file
        nc
        exit 2
    fi
}

main
