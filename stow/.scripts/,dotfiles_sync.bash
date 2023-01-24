#!/bin/bash

# This will auto commit, pull and push a given repository

# set -x
# set -e

DOTFILES=$1 # Can also sync other repos not just dotfiles. DOTFILES variable input can be any valid git repo.

[ -d $DOTFILES ] || ( echo Not a directory; exit 2 )

pushd $DOTFILES >/dev/null

if [ ! -d .git ]; then
    exit 0
fi

tmp_file="/tmp/dotfiles_sync_$$.log"

git status > "$tmp_file"

clean="0"
while read -r line; do
    if [[ "$line" =~ "nothing to commit, working tree clean" ]]; then
        clean="1"
    fi
done < "$tmp_file"


pwd
if [[ "$clean" == "1" ]]; then
    echo ""
else
    # git diff
    git status -s
    read -t 5 -p "Adding these changes in 5 seconds... Press ^C to cancel or type m to create a new commit message" message 
    if [ "$message" = "m" ]; then
        echo Enter Message:
        read -re message2
        git add . && git status -s
        git commit -m "$message2"
    else
        git add . && git status -s
        git commit -m "Reorganizing and Updating"
    fi
fi

# echo -e "Preparing to pull, merge and push.."
git fetch > /dev/null 
git merge --no-commit --no-ff main
if [ $? -ne 0 ]; then
    git merge --abort
    echo -e "${RED}MERGE FAILED... Running lazygit...${NC}" 
    lazygit
else
    git merge > /dev/null 
    git push > /dev/null 
fi

echo -e "${GREEN}Done${NC}" 

popd > /dev/null 

rm "$tmp_file"
