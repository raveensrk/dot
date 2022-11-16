#!/bin/bash
set -e
set -x

[ -d "$HOME/tmp" ] || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
[ -d "$HOME/.status" ] || mkdir -p "$HOME/.status"
bash add_sources.bash "[ -f ~/.bash_aliases ] && source ~/.bash_aliases" "$HOME/.bashrc"
bash add_sources.bash "[ -f ~/.bashrc ] && source ~/.bashrc" "$HOME/.bash_login"
stow -R stow -t "$HOME" --no-folding

# Not sure if this is required anymore
# chmod 644 "$HOME/.ssh/config"

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y  \
    flatpak \
    snap \
    snapd \
    autoconf \
    automake \
    cscope \
    curl \
    emacs \
    ffmpeg \
    ffmpegthumbnailer \
    firefox \
    git \
    gnome-software \
    gnuplot \
    htop \
    imagemagick \
    kdialog \
    kdiff3 \
    libssl-dev \
    mediainfo \
    mlocate \
    mpv \
    neofetch \
    newsboat \
    npm \
    obs-studio \
    octave \
    pandoc \
    pkg-config \
    python3 \
    python3-pip \
    qrencode \
    ranger \
    ripgrep \
    rsync \
    ruby \
    shellcheck \
    stow \
    tldr \
    urlview \
    vim \
    vim-gtk \
    x11-xserver-utils \
    yank \
    xclip \


    sudo apt install gnome-software-plugin-flatpak
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#flatpak install flathub org.mozilla.firefox

stow -R doom_emacs -t "$HOME" --no-folding

if [ ! -e ~/.emacs.d/bin/doom ]; then
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
    ~/.emacs.d/bin/doom install
    ~/.emacs.d/bin/doom sync
else
    echo Doom exists...
fi

if [ ! -e ~/.fzf/bin/fzf ]; then
    git clone --depth 1 "git@github.com:junegunn/fzf.git" ~/.fzf
fi
"$HOME/.fzf/install" --all

# https://colemak.com/Unix
[ ! -d ~/.tmp ] && mkdir ~/.tmp
pushd ~/.tmp
wget -nc "https://colemak.com/pub/unix/colemak-1.0.tar.gz"
tar xvf colemak-1.0.tar.gz
pushd colemak-1.0
setxkbmap us; xmodmap xmodmap/xmodmap.colemak && xset r 66
setxkbmap us -variant colemak
popd
popd
