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

echo -e "${YELLOW}Override options [Y/n]...${NC}"
read -r choice
if [ "$choice" = "Y" ]; then
    echo -e "${YELLOW}Choose machine...
    1. Work machine with internet
    2. Work machine with upload access only
    3. Personal machine with internet - ubuntu
    4. Personal machine with internet - fedora
    Enter option...
    ${NC}"
    read -r choice
    machine="$choice"
fi 
unset choice

echo -e "${YELLOW} Installing for machine $machine...${NC}"

# {{{ Packages installed with package manager

pkg_list_common="bat curl ffmpeg ffmpegthumbnailer gnuplot htop  kdialog kdiff3 mediainfo mlocate mpv neofetch newsboat python python3 python3-pip ranger stow tldr vim yank pandoc obs-studio urlview ruby autoconf pkg-config automake"
pkg_list_ubuntu_only="shellcheck imagemagick vim-gtk libssl-dev"
pkg_list_fedora_only="ShellCheck ImageMagick vim-X11 openssl-devel"

case $machine in
    4)
        sudo dnf install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        sudo dnf install  $pkg_list_common
        sudo dnf install  $pkg_list_fedora_only
        ;;
    1|3)
        sudo apt-get update
        # sudo apt-get upgrade
        sudo apt-get autoremove
        sudo apt-get autoclean
        echo -e "${BLUE}Do you want to reinstall apt packages from internet? [Y/n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            sudo apt-get install -y $pkg_list_common
            sudo apt-get install -y $pkg_list_ubuntu_only
            sudo apt-get install -y lftp=4.8.1-1ubuntu0.1 --allow-downgrades || echo -e "${YELLOW}LFTP install failed...${NC}"
            sudo gem install jekyll bundler || echo -e "${YELLOW}Warning: Jekyll installer failed.${NC}"
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

pushd "$csd"
# [ -f "$HOME/.inputrc" ] && rm -ivf "$HOME/.inputrc"
stow -R stow -t "$HOME" --no-folding || exit 2

echo -e "${YELLOW}Install Display environment for WSL2? [Y/n]...${NC}"
read -r choice
if [ "$choice" = "Y" ]; then
    stow -R stow_wsl2_scripts -t "$HOME" --no-folding || exit 2
fi 
unset choice

[ -d stow_vim_plugins ] && stow -R stow_vim_plugins -t "$HOME" || exit 2
popd

git clone --depth 1 "https://github.com/junegunn/fzf.git" "$csd/stow_vim_plugins/.fzf" || echo -e "${YELLOW}Not cloning. $csd/.fzf already present...${NC}"
"$HOME/.fzf/install" --all || echo -e "${YELLOW}FZF install failed...${NC}"

pushd "$HOME/.packages"
./clone.bash || echo -e "${YELLOW}Packages already present...${NC}"
popd

ln -sf "$HOME/.packages/PathPicker-main/fpp" ~/.local/bin

git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" || echo -e "${YELLOW}TPM already exists...${NC}"

if sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o "$HOME/.local/bin/youtube-dl"; then
    sudo chmod a+rx "$HOME/.local/bin/youtube-dl"
else
    echo -e "${YELLOW}youtube-dl not installed...${NC}" 
fi

exit 0
