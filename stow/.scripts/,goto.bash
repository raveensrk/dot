#!/bin/bash

help () {
    echo -e "${BLUE} TODO: Write help.${NC}"
    exit 0
}

set -e

while [ "$1" ]; do
    case "$1" in
        --input|-i)
            shift
            input="$1"
            ;;
        --ext)
            shift
            ext="$1"
            ;;
        --help|-h)
            help
            ;;
        *)
            echo -e "${RED}❌ ERROR! WRONG Argument!${NC}"
            exit 2
            ;;
    esac
    shift
done

if [ "$input" != "" ]; then
    pushd "$input" || exit 2
fi

selection="/tmp/,goto_selection_$$.txt"


if [ "$ext" != "" ]; then
    grep --include="*.$ext" --exclude-dir=.git --exclude-dir=.hg -H -n -r . | fzf -m -e > "$selection"
else
    # item=$(grep --exclude-dir=.git --exclude-dir=.hg -H -n -r . | fzf -e )
    rg -L -n --no-heading -. . --ignore-file "$HOME/.scripts/.ignore" | fzf -m -e > "$selection"
fi


while read -r -u5 item; do
    # echo "$item"
    file=$(echo "$item" | awk -F ':' '{print $1}')
    # echo "$file"
    line=$(echo "$item" | awk -F ':' '{print $2}')
    # echo "$line"
    file_absolute_path="$file"
    # echo -e "${YELLOW}Selection: \"$item\"${NC}" 
    # echo -e "${YELLOW}Command: vim -c \":$line\" \"$file_absolute_path\"${NC}" 

    servername=$(vim --serverlist | head -1)

    set -x
    if [ "$servername" = "" ]; then
        vim --servername VIM --remote "$file_absolute_path"
        vim --servername VIM --remote-send ":$line<CR>"
    else
        vim --servername $servername --remote "$file_absolute_path"
        vim --servername $servername --remote-send ":$line<CR>"
    fi 
    set +x

    unset servername

done 5< "$selection"

rm "$selection"

if [ "$input" != "" ]; then
    popd || exit 2
fi
