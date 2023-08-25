#!/bin/bash

xcode-select --install

if ! command -v brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update

packages=(
    fortune
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
    cscope  
    w3m  
    mactex  
    findutils
    tmux
    ispell
    wkhtmltopdf
    languagetool
    basictex
    lazygit
    espanso
    up
    poppler
    zoxide
    sqlite
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


bash ../add_sources.bash 'export PATH="/Library/TeX/texbin:$PATH"' "$HOME/.bashrc"

python3 -m pip install --upgrade pip
python3 -m pip install --user pynvim
python3 -m pip install --user yewtube
