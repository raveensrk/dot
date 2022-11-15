#!/bin/bash
set -e
set -x

# [[file:install_everything.org::*Basic programs][Basic programs:1]]
[ -d "$HOME/tmp" ] || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
# Basic programs:1 ends here

sudo apt install -y  \
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

stow -R doom_emacs -t "$HOME" --no-folding
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
~/.emacs.d/bin/doom install
~/.emacs.d/bin/doom sync

git clone --depth 1 "git@github.com:junegunn/fzf.git" ./stow_vim_plugins/.fzf
stow -R stow_vim_plugins -t "$HOME"
"$HOME/.fzf/install" --all
