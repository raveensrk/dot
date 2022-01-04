#!/bin/bash

# This will auto commit, pull and push a given repository

# set -x
# set -e

DOTFILES=$1 # Can also sync other repos not just dotfiles. DOTFILES variable input can be any valid git repo.

[ -d $DOTFILES ] || ( echo Not a directory; exit 2 )

pushd $DOTFILES

if [ ! -d .git ]; then
    exit 0
fi


git status | tee /tmp/dotfiles_sync.bash.tmp
grep "nothing to commit, working tree clean" /tmp/dotfiles_sync.bash.tmp

if [[ $? == 0 ]]; then
    echo -e "${GREEN} Nothing to commit ${NC} ✅"
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

    read -p "Enter commit message or leave it empty for default commit message: " commit_msg

    if [[ "$commit_msg" == "" ]]; then
        git commit -m "Sync commit from $USER@$HOSTNAME"
    else
        git commit -m "$commit_msg"
    fi

fi

echo -e "${YELLOW} Preparing to pull, merge and push... ${NC} "
git pull
git push
echo -e ${GREEN} Done ${NC} ✅ 

popd
