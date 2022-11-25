#!/bin/bash

source ~/.bash_prompt 

help () {
    less "$0"
}

input="$HOME/my_repos"

pushd "$input" || exit 2
find . | grep ".DS_Store" | grep -v ",clean_up_.DS_Store.bash" | xargs rm -fv
popd || exit 2
