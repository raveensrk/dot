#!/bin/bash

# https://blog.ivansmirnov.name/script-mouse-buttons-control-i3wm/
if [ $HOSTNAME != my-fedora ]; then
	printf "This script is only to be used for my-fedora computer\n"
	exit 1
fi

command -v xinput > /dev/null 
[ $? != 0 ] && sudo dnf install xinput
command -v xev > /dev/null
[ $? != 0 ] && sudo dnf install xev

ID=$(xinput list | grep M720 | grep pointer | awk '{print $6}' |  cut -d'=' -f 2)
echo $ID > /dev/null

printf "This will setup left handed mouse operation\n. Press any key to continue...\n"  > /dev/null
# read tmp

xinput --set-button-map $ID 3 2 1 4 5 6 7 8 9 0 0

