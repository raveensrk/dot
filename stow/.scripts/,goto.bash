#!/bin/bash

set -e

while [ "$1" ]; do
    case "$1" in
        --ext)
            shift
            ext="$1"
            ;;
        --help)
            echo -e "${BLUE} TODO: Write help.${NC}"
            exit 2
            ;;
        *)
            echo -e "${RED}❌ ERROR! WRONG Argument!${NC}"
            exit 2
            ;;
    esac
    shift
done

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
    vim -c ":$line" "$file_absolute_path"
done 5< "$selection"

rm "$selection"
