#!/bin/bash

source ~/.bash_prompt 

pushd "$1"

for file in *; do
    if [ -f "$file" ]; then
        yellow
        echo "$file"
        nc
        dir_name=$(ls -l --time-style=full-iso "$file" | cut -f6 -d' ' | cut -f1,2 -d'-')
        echo "$dir_name"
        [ ! -d "$dir_name" ] && mkdir "$dir_name"
        mv -iv "$file" "$dir_name"
    fi
done

popd
