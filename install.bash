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
        --rebuild)
            rebuild="y"
            ;;
        *)
            echo -e "${RED}❌ ERROR! WRONG Argument!${NC}"
            exit 2
            ;;
    esac
    shift
done

echo -e "${YELLOW}Override options [y/n]...${NC}"
read -e choice
if [ "$choice" = "y" ]; then
    echo -e "${YELLOW}Choose distro [f/u/m/*]...${NC}"
    read -e choice
    distro="$choice"
    echo -e "${YELLOW}Choose rebuild [y/n]...${NC}"
    read -e choice
    rebuild="$choice"
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
        sudo apt  update
        sudo apt  upgrade
        sudo apt  autoremove
        sudo apt  autoclean
        sudo apt  install $pkg_list_common
        sudo apt  install $pkg_list_ubuntu_only
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

if [ "$distro" = "u" ] || [ "$distro" = "f" ]; then
    git clone --depth 1 "https://github.com/junegunn/fzf.git" "$csd/stow_vim_plugins/.fzf" || echo -e "${YELLOW}Not cloning. $HOME/.fzf already present...${NC}"
fi

pushd "$csd"
# [ -f "$HOME/.inputrc" ] && rm -ivf "$HOME/.inputrc"
stow -R stow -t "$HOME" --no-folding
stow -R stow_vim_plugins -t "$HOME"
popd


if [ "$distro" = "m" ]; then

    pushd "$HOME/.packages"
    if [ "$rebuild" = "y" ]; then
        pushd libevent-*/
        ./configure --prefix=$HOME/.local --enable-shared
        make -j
        make install -j
        pushd

        # https://github.com/tmux/tmux/wiki/Installing#building-dependencies
        pushd tmux-2.6
        PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig ./configure --prefix=$HOME/.local
        make -j
        make install -j
        popd

        pushd vim82
        ./configure --prefix="$(HOME)/.local" # defaults to /usr/local
        make -j
        make install -j
        popd

        pushd ctags
        ./autogen.sh
        ./configure --prefix="$(HOME)/.local" # defaults to /usr/local
        make -j
        make install -j # may require extra privileges depending on where to install
        popd
    fi
    popd
elif [ "$distro" = "u" ] || [ "$distro" = "f" ]; then

    pushd "$HOME/.packages"
    ./clone.bash
    popd

    gem install jekyll bundler

    git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" || echo -e "${YELLOW}TPM already exists...${NC}"

    curl -sL "https://raw.githubusercontent.com/pystardust/ytfzf/master/ytfzf" | sudo tee $HOME/.local/bin/ytfzf >/dev/null && sudo chmod 755 $HOME/.local/bin/ytfzf

    sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o $HOME/.local/bin/youtube-dl
    sudo chmod a+rx $HOME/.local/bin/youtube-dl

fi

"$HOME/.fzf/install" || echo -e "${YELLOW}FZF install failed...${NC}"
ln -sf "$(realpath "$HOME/.packages/PathPicker/fpp")" ~/.local/bin

# TODO add urlview as a manual install
