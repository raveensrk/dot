#!/bin/bash

# set -e
# set -x

source ~/.bash_prompt

add_line="$1"
yellow
echo This following line will be added:
nc
echo $add_line

line_present=${line_present:-0}

declare -i count
count=0
while read -re line; do
    count=$(($count + 1))
    # echo Line: $count: $line
    if [ "$add_line" = "$line" ]; then
        yellow
        echo This following line is already present:
        nc
        echo $add_line
        line_present="1"
        break
    fi
done < ~/.bashrc

if [ "$line_present" != "1" ]; then
    echo "$add_line" >> ~/.bashrc
fi

exit 0
