#!/bin/bash

# This will auto commit, pull and push a given repository

# set -x
# set -e

DOTFILES=$1 # Can also sync other repos not just dotfiles. DOTFILES variable input can be any valid git repo.

[ -d $DOTFILES ] || ( echo Not a directory; exit 2 )

pushd $DOTFILES

if [ -f "./Makefile" ]; then
  make clean  
fi

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


if [[ "$clean" == "1" ]]; then
    echo "Nothing to commit"
else
    git diff
    git status
    pwd
    read -p "Add these changes? [y/n]: " choice
    if [[ $choice == y ]]; then
        git add . && git status
    else
        echo -e "${YELLOW} Skipping add and commit for $DOTFILES ${NC} "
        exit 0
    fi

    echo -e "${YELLOW}Enter commit message or leave it empty for default commit message:${NC}"
    read -re commit_msg

    if [[ "$commit_msg" == "" ]]; then
        git commit -m "Sync commit from $USER@$HOSTNAME"
    else
        git commit -m "$commit_msg"
    fi

fi

echo -e "${YELLOW} Preparing to pull, merge and push... ${NC} "
git pull
git push
echo -e "${GREEN}Done${NC}✅" 

popd


rm "$tmp_file"
