#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'



check_dir () {
    local dir="$1"
    [ -d $HOME/.$dir ] || exit 2 # Exit script if the directory is not present
    local list_of_new_scripts=()
    readarray -t list_of_new_scripts < <(find $HOME/.$dir -type f | grep -v "custom")
    for f in "${list_of_new_scripts[@]}"; do
        echo "$f"
        name=$(basename "$f")
        echo "where do you want to move this file?"
        location=$(fzf --height=30% < <(find $HOME/my_repos | grep "\.$dir$"; echo "$HOME/.$dir"))
        command mv -iv "$f" "$location"
    done
}

check_dir "scripts"
check_dir "my_bash_aliases"
