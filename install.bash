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
            rebuild="Y"
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
    echo -e "${YELLOW}Choose rebuild [Y/n]...${NC}"
    read -r choice
    rebuild="$choice"
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
        sudo apt  update
        sudo apt  upgrade
        sudo apt  autoremove
        sudo apt  autoclean
        sudo apt  install -y $pkg_list_common
        sudo apt  install -y $pkg_list_ubuntu_only
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
[ ! -d "$HOME/.packages_extracted" ] && mkdir "$HOME/.packages_extracted"

if [ "$distro" = "u" ] || [ "$distro" = "f" ]; then
    git clone --depth 1 "https://github.com/junegunn/fzf.git" "$csd/stow_vim_plugins/.fzf" || echo -e "${YELLOW}Not cloning. $csd/.fzf already present...${NC}"
    pushd "$HOME/.packages"
    ./clone.bash || echo -e "${YELLOW}Packages already present...${NC}"
    popd
fi

pushd "$csd"
# [ -f "$HOME/.inputrc" ] && rm -ivf "$HOME/.inputrc"
stow -R stow -t "$HOME" --no-folding
stow -R stow_vim_plugins -t "$HOME"
popd

if [ "$distro" = "m" ]; then

    pushd "$HOME/.packages"
    if [ "$rebuild" = "Y" ]; then
        for f in *.tar*; do
            tar xf "$f" --directory="$HOME/.packages_extracted"
        done
        for f in *.zip; do
            unzip "$f" -d ~/.packages_extracted
        done
    fi
    popd

    pushd "$HOME/.packages_extracted"
    if [ "$rebuild" = "Y" ]; then
        echo -e "${BLUE}Do you want to install libevent? [Y/n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            pushd libevent-*/
            ./configure --prefix="$HOME/.local" --enable-shared
            make -j
            make install -j
            pushd
        fi 
        unset choice

        echo -e "${BLUE}Do you want to install libevent? [Y/n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            # https://github.com/tmux/tmux/wiki/Installing#building-dependencies
            pushd tmux-2.6
            PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig ./configure --prefix="$HOME/.local"
            make -j
            make install -j
            popd
        fi 
        unset choice

        echo -e "${BLUE}Do you want to install libevent? [Y/n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            pushd vim82
            ./configure --prefix="$HOME/.local" # defaults to /usr/local
            make -j
            make install -j
            popd
        fi 
        unset choice

        echo -e "${BLUE}Do you want to install libevent? [Y/n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            pushd ctags
            ./autogen.sh
            ./configure --prefix="$HOME/.local" # defaults to /usr/local
            make -j
            make install -j # may require extra privileges depending on where to install
            popd
        fi 
        unset choice

        echo -e "${BLUE}INSTALL BASH Completions? [Y/n] [Default n]:${NC}"
        read -r choice
        if [ "$choice" = "Y" ]; then
            pushd ~/.packages_extracted/bash-completion-2.11
            autoreconf -i  # if not installing from prepared release tarball
            ./configure --prefix="$HOME/.local"
            make -j         # GNU make required
            make check -j     # optional, requires python3 with pytest >= 3.6, pexpect
            make install -j   # as root
            popd
        fi 
        unset choice

    # TODO add urlview as a manual install
    # TODO install stow manual
    fi # rebuild
    popd # .packages_extracted
elif [ "$distro" = "u" ] || [ "$distro" = "f" ]; then
    git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" || echo -e "${YELLOW}TPM already exists...${NC}"
    curl -sL "https://raw.githubusercontent.com/pystardust/ytfzf/master/ytfzf" | sudo tee "$HOME/.local/bin/ytfzf" >/dev/null && sudo chmod 755 "$HOME/.local/bin/ytfzf"
    sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o "$HOME/.local/bin/youtube-dl"
    sudo chmod a+rx "$HOME/.local/bin/youtube-dl"
fi

ln -sf "$HOME/.packages_extracted/PathPicker-main/fpp" ~/.local/bin

echo -e "${BLUE}Do you want to install fzf? [Y/n]:${NC}"
read -r choice
if [ "$choice" = "Y" ]; then
    "$HOME/.fzf/install" || echo -e "${YELLOW}FZF install failed...${NC}"
fi 
unset choice

