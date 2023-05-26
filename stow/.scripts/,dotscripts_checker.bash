#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

[ -d $HOME/.scripts ] || exit 0 # Exit script if the directory is not present


readarray -t list_of_new_scripts < <(find $HOME/.scripts -type f)

new_files=()
for f in "${list_of_new_scripts[@]}"; do
    echo "$f"
    name=$(basename "$f")
    echo "where do you want to move this file?"
    location=$(fzf --height=30% < <(find $HOME/my_repos | grep "\.scripts$"; echo "$HOME/.scripts"))
    command mv -iv "$f" "$location"
done

