#!/bin/bash

set -e

while [ "$1" ]; do
    case "$1" in
        --path)
            shift
            path="$1"
            ;;
        --list)
            shift
            list="$1"
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

selection="/tmp/selection_$$"

if [ "$path" = "" ] && [ "$list" = "" ] ; then
    echo -e "${RED}❌ ERROR! No Argument!${NC}"
    exit 2
fi

if [ "$path" != "" ] && [ "$list" != "" ] ; then
    echo -e "${RED}❌ ERROR! Both Argument provided. Choose only one!${NC}"
    exit 2
fi

if [ "$path" != "" ]; then
    pushd "$path" || exit
    realpath ./* | fpp --all-input -c "realpath > $selection" 
    cat "$selection"
    popd || exit
fi

if [ "$list" != "" ]; then
    cat "$list" > "$selection" 
fi

data="/tmp/data_$$"
while read -r d; do
    pushd "$d" || exit
    echo -e "${YELLOW}++${NC}"
    if [ -d ".git" ]; then
        string=$(git grep --full-name -n . | sort)
    else
        string=$(grep --include="*.md" -r -n . | sort)
    fi
    echo "$string" | sed "s|^|$d/|">> "$data"
    popd || exit
done < "$selection"

item=$(fzf -e < "$data")
file=$(echo "$item" | awk -F ':' '{print $1}')
line=$(echo "$item" | awk -F ':' '{print $2}')
file_absolute_path="$file"

vim -c ":$line" "$file_absolute_path"
