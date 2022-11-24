#!/bin/bash

source ~/.bash_prompt 

help () {
    less "$0"
}

input="$HOME/my_repos"

pushd "$input" || exit 2
find . | grep ".DS_Store" | xargs rm -fv
popd || exit 2
