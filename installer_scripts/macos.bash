#!/bin/bash

if ! command -v brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update

packages=(
    graphicsmagick  
    autoconf  
    automake  
    bat  
    curl  
    ffmpeg  
    ffmpegthumbnailer  
    gnuplot  
    htop  
    imagemagick  
    dialog  
    mediainfo  
    mpv  
    neofetch  
    newsboat  
    pandoc  
    pkg-config  
    python  
    ranger  
    ripgrep  
    ruby  
    shellcheck  
    stow  
    tldr  
    urlview  
    vim  
    yank  
    wget  
    lesspipe  
    rsync  
    grep  
    bfg  
    jq  
    emacs  
    cscope  
    w3m  
    mactex  
    findutils
)

for package in "${packages[@]}"; do
    if brew install --cask "$package"; then
        echo "Package $package, installed as cask..."
    else
        brew install "$package"
        echo "Package $package, installed as not cask..."
    fi    
done

