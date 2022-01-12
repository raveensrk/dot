#!/bin/bash

# This script will install all application for my system after cloning
# my repo and symlinking my dotfiles. Supports fedora and ubuntu.

set -e
# set -x

# Current script dir csd
csd=$(dirname "$0")

while [ "$1" ]; do
    case "$1" in
        --distro)
            shift
            distro="$1"
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
    echo -e "${YELLOW}Choose distro [f/u/m/*]...${NC}"
    read -r choice
    distro="$choice"
    unset choice
fi 

echo -e "${YELLOW} Installing for distro $distro...${NC}"

# {{{ Packages installed with package manager

pkg_list_common="bat curl ffmpeg ffmpegthumbnailer gnuplot htop  kdialog kdiff3 mediainfo mlocate mpv neofetch newsboat python python3 python3-pip ranger stow tldr vim yank pandoc obs-studio urlview ruby autoconf pkg-config automake"
pkg_list_ubuntu_only="shellcheck imagemagick vim-gtk libssl-dev"
pkg_list_fedora_only="ShellCheck ImageMagick vim-X11 openssl-devel"

case $distro in
    f)
        sudo dnf install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        sudo dnf install  $pkg_list_common
        sudo dnf install  $pkg_list_fedora_only
        ;;
    u)
        # sudo apt-get update
        # sudo apt-get upgrade
        # sudo apt-get autoremove
        # sudo apt-get autoclean
        sudo apt-get install -y $pkg_list_common
        sudo apt-get install -y $pkg_list_ubuntu_only
        sudo apt-get install -y lftp=4.8.1-1ubuntu0.1 --allow-downgrades || echo -e "${YELLOW}LFTP install failed...${NC}"
        sudo gem install jekyll bundler || echo -e "${YELLOW}Warning: Jekyll installer failed.${NC}"
        ;;
    n)
        echo "Skipping install.."
        ;;
    m)
        echo -e "${BLUE}Manual install...${NC}"
        ;;
    *)
        echo "Unknown Distro! 😠"
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
stow -R stow_vim_plugins -t "$HOME" || exit 2
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

tar cf stow_vim_plugins.tar.gz stow_vim_plugins

exit 0
