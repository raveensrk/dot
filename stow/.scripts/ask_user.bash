#!/bin/bash

source ~/.bash_prompt

while [ "$1" ]; do
    case "$1" in
        --msg|-m)
            shift
            msg="$1"
            ;;
        *)
            red
            echo Wrong Option!
            nc
            ;;
    esac
    shift
done

yellow
echo "Do you want to $msg? [Y/n]"
nc
read -re choice

if [ "$choice" != "Y" ]; then
    exit 3
else
    exit 0
fi
