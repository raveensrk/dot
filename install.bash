#!/bin/bash

# Install some basic stuff

set -e
# set -x

[ -d "$HOME/tmp" ] || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"

if [ -f "~/.emacs" ]; then
    yellow
    echo ~/.emacs is present
    nc

    cat ~/.emacs
    
    blue
    echo Do you want to remove ~/.emacs? [Y/n]
    nc
    
    read -re choice
    if [ $choice = "Y" ]; then
	    rm -iv ~/.emacs
    else
	    red
	    echo Cannot proceed without removing ~/.emacs file.
	    exit 2
	    nc
    fi
fi


make install_basic


exit 0
