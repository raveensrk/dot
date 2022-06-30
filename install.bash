#!/bin/bash

# -*- outline-regexp: "### [A-za-z0-9 -_]+"; -*-
# Local Variables:
# eval: (outline-minor-mode 1)
# End:

# This script will install all application for my system after cloning
# my repo and symlinking my dotfiles. Supports fedora and ubuntu.

set -e
# set -x

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)
BLUE=$(tput setaf 4)
red () {
    tput setaf 1
}

green () {
    tput setaf 2
}

yellow () {
    tput setaf 3
}

blue () {
    tput setaf 4
}

nc () {
    tput sgr0
}


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


# Current script dir csd
csd=$(dirname "$0")

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

echo -e "${YELLOW} Installing for machine $machine...${NC}"

# {{{ Packages installed with package manager

case $machine in
    5)
        if ! command -v brew; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi 
        brew install $(xargs < ./packages_list_osx.txt)
	    ;;
    4)
        sudo dnf install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        sudo dnf install  $(xargs < ./packages_list_fedora.txt)
        ;;
    1|3)
        echo -e "${BLUE}Do you want to reinstall apt packages from internet? [Y/n]:${NC}"
        echo -e "${BLUE}You have 5 seconds to answer!${NC}"
        TMOUT=5
        read -r choice
        TMOUT=0
        if [ "$choice" = "Y" ]; then
            sudo apt-get update
            # sudo apt-get upgrade
            sudo apt-get autoremove
            sudo apt-get autoclean
            sudo apt-get install -y $(xargs < packages_list_ubuntu.txt)
            sudo apt-get install -y lftp=4.8.1-1ubuntu0.1 --allow-downgrades || echo -e "${YELLOW}LFTP install failed...${NC}"
        fi
        unset choice
        ;;
    6)
        echo -e "${BLUE}Do you want to reinstall apt packages from internet? [Y/n]:${NC}"
        echo -e "${BLUE}You have 5 seconds to answer!${NC}"
        TMOUT=5
        read -r choice
        TMOUT=0
        if [ "$choice" = "Y" ]; then
            sudo apt-get update
            # sudo apt-get upgrade
            sudo apt-get autoremove
            sudo apt-get autoclean
            sudo apt-get install -y $(xargs < packages_list_ubuntu_20.txt)
            sudo apt-get install -y lftp=4.8.1-1ubuntu0.1 --allow-downgrades || echo -e "${YELLOW}LFTP install failed...${NC}"
        fi
        unset choice
        ;;
    2)
        echo -e "${YELLOW}Skipping internet based install..${NC}"
        ;;
    7)
        echo -e "${YELLOW}Installing for work machine with internet but with no root access and no wsl...${NC}"
	yellow
	echo "Setting the emacs and vim as flatpak version..."
	nc
	emacs () {
	    flatpak run org.gnu.emacs --display $DISPLAY
	}

	vim () {
	    flatpak run org.vim.Vim
	}
        ;;
    *)
        echo "Unknown machine! 😠" 
        ;;
esac

# }}} 

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
        make install_colemak
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

if [[ ! -d "$HOME/.fzf/.git" ]]; then
    git clone --depth 1 "git@github.com:junegunn/fzf.git" \
        "$csd/stow_vim_plugins/.fzf"
fi

if ! command -v fzf; then
    "$HOME/.fzf/install" --all || echo -e "${YELLOW}FZF install failed...${NC}"
fi

pushd "$HOME/.packages"
./clone.bash
popd

if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
    git clone "git@github.com:tmux-plugins/tpm.git" "$HOME/.tmux/plugins/tpm"
fi

if ! command -v yt-dlp; then
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
    chmod a+rx ~/.local/bin/yt-dlp
fi


### Exit

exit 0
