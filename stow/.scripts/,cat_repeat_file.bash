#!/bin/bash 

# Basically this command will find a file in my ~/.projects and cat it into the termainal and keep refreshing

readarray -t files < <(find -L $(cat ~/.projects) -iname "*$1*")

if command -v batcat > /dev/null; then
    cat="batcat --color always"
fi

for file in "${files[@]}"; do
    tmux split-window -h -c "#{pane_current_path}" "watch -c $cat \"$file\""
done
