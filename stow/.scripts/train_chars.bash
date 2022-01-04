#!/bin/bash

# NOTE: Need to check gtypist program that might be more useful than
# this

# Script to help me type better
# Typing tutor - colemak layout
# Notation:
# l* - left hand
# r* - right hand
# *i - index finger
# *m - middle finger
# *r - ring
# *p - pinky

# set -x
set -e

dir=$(dirname "$0")
pushd $dir

while true; do
    char=$(cat train_charset.txt | head -8 | shuf | head -1)
    char_only=$(echo $char | awk -F ',' '{print $2}')
    echo -en "${YELLOW} $char_only ${NC} "
    read -n 1 input
    if [ $input = $char_only ] ; then
        echo -e ${GREEN} $char ${NC}
    elif [ $input != $char ] ; then
        echo $char,0 >> train_status.log
        echo -e ${RED} $char ${NC}
        echo $char,1 >> train_status.log
    fi
done

popd
