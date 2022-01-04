#!/bin/bash

# This script will install all application for my system after cloning
# my repo and symlinking my dotfiles. Supports fedora and ubuntu.

set -e
# set -x

# Current script dir csd
csd=$(dirname "$0")

# {{{ Packages installed with package manager
while [ "$1" ]; do
    case "$1" in
        --distro)
            shift
            distro="$1"
            ;;
        --rebuild)
            rebuild="1"
            ;;
        *)
            echo -e "${RED}❌ ERROR! WRONG Argument!${NC}"
            exit 2
            ;;
    esac
    shift
done

echo -e "${YELLOW} Installing for distro $distro...${NC}"

pkg_list_common="bat curl ffmpeg ffmpegthumbnailer gnuplot htop  kdialog kdiff3 mediainfo mlocate mpv neofetch newsboat python python3 python3-pip ranger stow tldr vim yank pandoc obs-studio urlview ruby"
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

pushd "$csd"
# [ -f "$HOME/.inputrc" ] && rm -ivf "$HOME/.inputrc"
stow -R stow -t "$HOME" --no-folding
popd

if [ "$distro" = "m" ]; then

    if [ ! -d "$HOME/.fzf" ]; then
        #git clone --depth 1 "https://github.com/junegunn/fzf.git" "$HOME/.fzf"
        # "$HOME/.fzf/install"
        tar xf ./stow/.packages/fzf.tar.gz --directory="$HOME"
        mv ~/fzf ~/.fzf
    fi

    if [ ! -d "$HOME/.packages/ranger-stable" ]; then
        #git clone --depth 1 "https://github.com/junegunn/fzf.git" "$HOME/.fzf"
        # "$HOME/.fzf/install"
        pushd "$HOME/.packages"
        tar xf ranger-stable.tar.gz
        popd
    fi

    pushd "$HOME/.tmux/plugins"
    for file in *.tar.gz; do
        tar xf "$file"
    done
    popd

    pushd "$HOME/.packages"

    tar xf "path-picker.tar.gz"
    ln -sf $(realpath ~/.packages/PathPicker-main/fpp) ~/.local/bin
    # https://github.com/tmux/tmux/wiki/Installing#building-dependencies

    if [ "$rebuild" = "1" ]; then
        tar -zxf libevent-*.tar.gz
        pushd libevent-*/
        ./configure --prefix=$HOME/.local --enable-shared
        make -j
        make install -j
        pushd

        tar xf "tmux-2.6.tar.gz"
        pushd tmux-2.6
        PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig ./configure --prefix=$HOME/.local
        make -j
        make install -j
        popd
    fi

    popd

    pushd ~/.vim/plugged
    for file in *.tar.gz; do
        tar xf "$file"
    done
    popd

fi

# pushd "$csd"
# [ -f "$HOME/.local/bin/fpp" ] && rm "$HOME/.local/bin/fpp"
# ln -s "$(realpath "./stow/.packages/PathPicker-main/fpp")" "$HOME/.local/bin/fpp"
# popd


# [ ! -f "$HOME/.vim/autoload/plug.vim" ] && \
#	curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
#		 "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# curl -sL "https://raw.githubusercontent.com/pystardust/ytfzf/master/ytfzf" | sudo tee $HOME/.local/bin/ytfzf >/dev/null && sudo chmod 755 $HOME/.local/bin/ytfzf

# sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o $HOME/.local/bin/youtube-dl
# sudo chmod a+rx $HOME/.local/bin/youtube-dl
