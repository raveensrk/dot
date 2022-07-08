#!/bin/bash

# -*- outline-regexp: "### [A-za-z0-9 -_]+"; -*-
# Local Variables:
# eval: (outline-minor-mode 1)
# End:

# This script will install all application for my system after cloning
# my repo and symlinking my dotfiles. Supports fedora and ubuntu.

set -e
# set -x

# Current script dir csd
csd=$(dirname "$0")

pushd "$csd"
popd


requirements=(stow)

for item in "${requirements[@]}"; do
    echo checking if $item is present...
    if command -v $item; then
	    echo -e "$GREEN$item present...$NC"
    else
	    echo -e "$RED$item not present...$NC"
	    echo -e "$RED$Script exitting...$NC"
	    exit 2
    fi
done


while [ "$1" ]; do
    case "$1" in
        --machine)
            shift
            machine="$1"
            ;;
        *)
            echo -e "${RED}❌ ERROR! WRONG Argument!${NC}"
            exit 2
            ;;
    esac
    shift
done

while read -r line; do
    if [[ "$USER@$HOSTNAME" == "$(echo "$line" | awk -F , '{print $2}')" ]]; then
        machine="$(echo "$line" | awk -F , '{print $1}')"
    fi
done < hostlist.txt

if [[ "$machine" == "" ]]; then
    echo -e "${RED}Machine variable unset. Add your machine to the hostlist.txt file.${NC}"
fi

[ -d "$HOME/tmp" ] || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
[ ! -d "$HOME/.vim/undo" ] && mkdir -p "$HOME/.vim/undo"
[ ! -d "$HOME/.vim/backup" ] && mkdir -p "$HOME/.vim/backup"
[ ! -d "$HOME/.vim/swap" ] && mkdir -p "$HOME/.vim/swap"

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

stow () {
    command stow --ignore=.DS_Store $@
}

pushd "$csd"
# [ -f "$HOME/.inputrc" ] && rm -ivf "$HOME/.inputrc"
stow -R stow -t "$HOME" --no-folding || exit 2


case "$machine" in
    1|3)
        stow -R stow_wsl2_scripts -t "$HOME" --no-folding || exit 2
        ;;
    1|2|3|4|6|7)
        stow -R stow_linux -t "$HOME" --no-folding || exit 2
        ;;
    5)
        stow -R stow_macos -t "$HOME" --no-folding || exit 2
        ;;
    *)
        echo Unknown machine for stow operation...
        ;;
esac

[ -d stow_vim_plugins ] && stow -R stow_vim_plugins -t "$HOME" || exit 2

popd

# Install plugins as required inside the editor
# vim -c "PlugInstall | PlugClean | qa"
# pushd packages
# vim -c "source install.vim | q"
# popd
# emacs -nw -f my-package-refresh-and-install-selected-packages --kill



exit 0
