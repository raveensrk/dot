#!/bin/bash

# This script will install all application for my system after cloning
# my repo and symlinking my dotfiles. Supports fedora and ubuntu.

set -e
# set -x

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
        sudo apt-get update
        # sudo apt-get upgrade
        sudo apt-get autoremove
        sudo apt-get autoclean
        echo -e "${BLUE}Do you want to reinstall apt packages from internet? [Y/n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            sudo apt-get install -y $(xargs < packages_list_ubuntu.txt)
            sudo apt-get install -y lftp=4.8.1-1ubuntu0.1 --allow-downgrades || echo -e "${YELLOW}LFTP install failed...${NC}"
        fi
        unset choice
        ;;
    6)
        sudo apt-get update
        # sudo apt-get upgrade
        sudo apt-get autoremove
        sudo apt-get autoclean
        echo -e "${BLUE}Do you want to reinstall apt packages from internet? [Y/n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            sudo apt-get install -y $(xargs < packages_list_ubuntu_20.txt)
            sudo apt-get install -y lftp=4.8.1-1ubuntu0.1 --allow-downgrades || echo -e "${YELLOW}LFTP install failed...${NC}"
        fi
        unset choice
        ;;
    2)
        echo -e "${YELLOW}Skipping internet based install..${NC}"
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

stow () {
    command stow --ignore=.DS_Store $@
}

pushd "$csd"
# [ -f "$HOME/.inputrc" ] && rm -ivf "$HOME/.inputrc"
stow -R stow -t "$HOME" --no-folding || exit 2

pushd packages
vim -c "source install.vim | q"
popd

case "$machine" in
    1|3)
        stow -R stow_wsl2_scripts -t "$HOME" --no-folding || exit 2
        ;;
    5)
        stow -R stow_macos -t "$HOME" --no-folding || exit 2
        ;;
esac


[ -d stow_vim_plugins ] && stow -R stow_vim_plugins -t "$HOME" || exit 2

popd

vim -c "PlugInstall | PlugClean | qa"

if [ "$machine" != "2" ]; then
    emacs -nw -f package-refresh-contents -f package-install-selected-packages -f package-autoremove --kill
fi 

if [[ ! -d "$HOME/.fzf/.git" ]]; then
    git clone --depth 1 "https://github.com/junegunn/fzf.git" \
        "$csd/stow_vim_plugins/.fzf"
fi

if ! command -v fzf; then
    "$HOME/.fzf/install" --all || echo -e "${YELLOW}FZF install failed...${NC}"
fi

pushd "$HOME/.packages"
./clone.bash
popd

ln -sf "$HOME/.packages/PathPicker-main/fpp" ~/.local/bin

if [[ ! -d "$HOME/.tmux/plugins/tpm/.git" ]]; then
    git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
fi

if ! command -v yt-dlp; then
    sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
    sudo chmod a+rx /usr/local/bin/yt-dlp
fi

exit 0
