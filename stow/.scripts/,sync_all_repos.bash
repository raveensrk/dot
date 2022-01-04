#!/bin/bash

set -e
# set -x

# This script will sync all repositories under given path

# read -e -p "Enter main top repo dir: " dir
# dir=$(realpath $dir)

# script_dir=$(dirname "$0")

dir="$(realpath "$1")"
echo "$dir" is top dir
pushd "$dir"
for d in $(find ./* -maxdepth 0 -type d); do
    clear
    ,dotfiles_sync.bash "$d"
done
popd
