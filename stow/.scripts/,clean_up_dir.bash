#!/bin/bash

source ~/.bash_prompt 

help () {
    less $0
}

while [ "$1" ]; do
    case "$1" in
        --input|-i)
            shift
            input="$1"
            ;;
        --help|-h)
            help
            exit 0
            ;;
        *)
            echo -e "${RED}Wrong option!${NC}"
            exit 2
            ;;
    esac
    shift
done 

yellow
echo Are you sure that you want to clean up this directory... [Y/n] ?
echo \"$input\"
nc

read -re choice

if [ "$choice" != "Y" ]; then
    yellow
    echo Not cleaning this directory... Exitting...
    nc
    exit 0
fi


pushd "$input"

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
