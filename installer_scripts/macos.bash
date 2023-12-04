#!/bin/bash

xcode-select --install

if ! command -v brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew update

packages=(
    # mpv  
    autoconf  
    automake  
    basictex
    bat  
    cmatrix
    cscope  
    curl  
    dialog  
    ffmpeg  
    ffmpegthumbnailer  
    findutils
    fortune
    gnuplot  
    graphicsmagick  
    grep  
    htop  
    iina  
    imagemagick  
    ispell
    jq  
    lazygit
    lesspipe  
    lolcat
    mactex  
    mediainfo  
    neofetch  
    newsboat  
    pandoc  
    pipes-sh
    pkg-config  
    poppler
    python  
    ranger  
    ripgrep  
    rsync  
    ruby  
    shellcheck  
    sqlite
    stow  
    tldr  
    tmux
    universal-ctags
    up
    urlview  
    vim  
    w3m  
    wget  
    zoxide
)

export HOMEBREW_NO_AUTO_UPDATE=1

for package in "${packages[@]}"; do
    if brew list --versions "$package"; then
        echo "Package $package, is already installed..."
    else
        if brew install --cask "$package"; then
            echo "Package $package, installed as cask..."
        else
            brew install "$package"
            echo "Package $package, installed as not cask..."
        fi
    fi
done

python3 -m pip install --upgrade pip
python3 -m pip install --user pynvim
