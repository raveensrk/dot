#!/bin/bash

set -e
# set -x

read -p "Choose distro: " distro

case $distro in
    fedora)
        sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install bat \
             curl \
             ffmpeg \
             ffmpegthumbnailer \
             gnuplot \
             htop \
             ImageMagick \
             kdialog \
             kdiff3 \
             mediainfo \
             mlocate \
             mpv \
             neofetch \
             newsboat \
             python \
             python3 \
             python3-pip \
             ranger \
             ShellCheck \
             stow \
             tldr \
             vim \
             yank \
             obs-studio \
             pandoc
        ;;
    ubuntu)
        sudo apt  update
        sudo apt  upgrade
        sudo apt  autoremove
        sudo apt  autoclean
        sudo apt  autopurge
        sudo apt  install bat \
             curl \
             ffmpeg \
             ffmpegthumbnailer \
             gnuplot \
             htop \
             imagemagick \
             kdialog \
             kdiff3 \
             mediainfo \
             mlocate \
             mpv \
             neofetch \
             newsboat \
             python \
             python3 \
             python3-pip \
             ranger \
             shellcheck \
             stow \
             tldr \
             vim \
             vim-gtk \
             yank
        ;;
    *)
        echo "Unknown Distro! 😠"
        exit 2
        ;;
esac


if [[ -d ~/dotfiles-personal ]]; then
    dotfiles=~/dotfiles-personal
elif [[ -d ~/.dotfiles-personal ]]; then
    dotfiles=~/.dotfiles-personal
else
    echo "Missing dotfiles repo!"
    exit 2
fi

pushd $dotfiles
stow  dotfiles -t ~/
popd

echo "source ~/.bash_aliases" >> ~/.bashrc

python3 -m pip install bdfr --upgrade

[ -d ~/tmp ] || mkdir $HOME/tmp
[ -d ~/.local/bin ] || mkdir -p ~/.local/bin

[ -d ~/.fzf ] && rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# [ -d ~/tmp/autojump ] && rm -rf ~/tmp/autojump
# git clone git://github.com/wting/autojump.git
# ~/tmp/autojump/install.py

# [ -d ~/tmp/ble.sh ] && rm -rf ~/tmp/ble.sh
# git clone --recursive https://github.com/akinomyoga/ble.sh.git
# make -C ble.sh install PREFIX=~/.local
# echo 'source ~/.local/share/blesh/ble.sh' >>~/.bashrc

pushd $HOME/.local/bin

[ -f ~/.local/bin/up ] && rm ~/.local/bin/up
wget https://github.com/akavel/up/releases/download/v0.3.2/up -O up
chmod +x up

[ -f ~/.local/bin/cht.sh ] && rm ~/.local/bin/cht.sh
curl https://cht.sh/:cht.sh >$HOME/.local/bin/cht.sh
chmod +x $HOME/.local/bin/cht.sh

curl -sL "https://raw.githubusercontent.com/pystardust/ytfzf/master/ytfzf" | sudo tee $HOME/.local/bin/ytfzf >/dev/null && sudo chmod 755 $HOME/.local/bin/ytfzf

curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o $HOME/.local/bin/youtube-dl
sudo chmod a+rx $HOME/.local/bin/youtube-dl

popd
