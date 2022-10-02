#!/bin/bash

source ~/.bash_prompt 

help () {
    less $0
}

input="$HOME/my_repos"

pushd "$input"

find . -iname ".DS_Store" | xargs rm -fv

popd
