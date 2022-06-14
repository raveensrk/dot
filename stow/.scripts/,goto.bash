#!/bin/bash

set -e

# HELP: This script uses fzf to print all the lines of text present in
# HELP: the current directory recrusively. Then it pipes it to fzf and
# HELP: allows the user to select the text, then it opens the file in the
# HELP: default "$EDITOR" with the cursor on that line. Also allows
# HELP: multiselection. Refer fzf multi selection option. Defaults to TAB
# HELP: key.
# Help: --------------
# Help: Example Usage:
# Help: --------------
# Help: ,goto.bash 
# Help: ,goto.bash --help
# Help: ,goto.bash --ext md
# Help: ,goto.bash --ext md --input /path/to/dir

help () {
    write_help.bash "$0"
}

while [ "$1" ]; do
    case "$1" in
        --input|-i)
            # HELP: --input|-i  This will get the input from the user
            shift
            input="$1"
            ;;
        --ext)
            # HELP: --ext  Only the extension will be filtered, example: md, org, bash
            shift
            ext="$1"
            ;;
        --help|-h)
            # HELP: --help|help  prints help
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


    if [ "$EDITOR" = "emacs -nw" ]; then
        echo "emacsclient -nw -a emacs -nw \"+$line\" \"$file_absolute_path\" "
        emacsclient -nw -a emacs -nw "+$line" "$file_absolute_path"
    else
        vim "$file_absolute_path" "+$line"
    fi
    

done 5< "$selection"

rm "$selection"

if [ "$input" != "" ]; then
    popd || exit 2
fi
