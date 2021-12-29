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
    *)
        echo "Unknown Distro! 😠"
        ;;
esac

# }}} 

[ -d "$HOME/tmp" ] || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"

# {{{ Stow packages
pushd "$csd"
[ -f "$HOME/.inputrc" ] && rm -ivf "$HOME/.inputrc"
stow stow -R -t "$HOME/"
popd

# pushd "$HOME/repos"
# bash "dotfiles-main/stow/.scripts/,stow_find_targets.bash" # FIXME
# popd
# }}}

# {{{ INDEPENDENT SOFTLINKS
pushd "$csd"
[ -f "$HOME/.local/bin/fpp" ] && rm "$HOME/.local/bin/fpp"
ln -s "$(realpath "./stow/.local/packages/PathPicker-main/fpp")" "$HOME/.local/bin/fpp"
popd
# }}} 

# {{{ FZF

if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 "https://github.com/junegunn/fzf.git" "$HOME/.fzf"
    "$HOME/.fzf/install"
fi

# }}}

# {{{ VIM
[ ! -d "$HOME/.vim/undo" ] && mkdir -p "$HOME/.vim/undo"
[ ! -d "$HOME/.vim/backup" ] && mkdir -p "$HOME/.vim/backup"
[ ! -d "$HOME/.vim/swap" ] && mkdir -p "$HOME/.vim/undo"

[ ! -f "$HOME/.vim/autoload/plug.vim" ] && \
	curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
		 "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
# }}}

# # {{{ CHEAT
# [ -f "$HOME/.local/bin/cht.sh" ] && rm "$HOME/.local/bin/cht.sh"
# curl "https://cht.sh/:cht.sh" > "$HOME/.local/bin/cht.sh"
# chmod +x "$HOME/.local/bin/cht.sh"
# # }}}

# curl -sL "https://raw.githubusercontent.com/pystardust/ytfzf/master/ytfzf" | sudo tee $HOME/.local/bin/ytfzf >/dev/null && sudo chmod 755 $HOME/.local/bin/ytfzf

# sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o $HOME/.local/bin/youtube-dl
# sudo chmod a+rx $HOME/.local/bin/youtube-dl

[ ! -v tldr ] && pip install tldr || echo -e "${YELLOW} tldr install failed ${NC}"

pushd "$HOME/tmp"

# {{{ ctags
command -v ctags || {
    sudo apt install autoconf pkg-config automake
    [ ! -d ctags ] && git clone "https://github.com/universal-ctags/ctags.git"
    pushd ctags
    ./autogen.sh
    ./configure --prefix="$HOME/.local" # defaults to /usr/local
    make -j
    make install -j # may require extra privileges depending on where to install
    popd
}
# }}} 

# {{{ VIM
# https://www.vim.org/git.php
command -v vim || {
    git clone "https://github.com/vim/vim.git"
    cd vim
    ./configure --prefix="$HOME/.local" # defaults to /usr/local
    make -j
    make install -j
    cd ..
}
# }}} 

# {{{ ENTR
# This program is used to watch for file changes.
# command -v entr || {
#     git clone "git@github.com:eradman/entr.git"
#     cd entr
#     ./configure
#     CFLAGS="-static" make test
#     PREFIX=$HOME/.local make install
#     cd ..
# }
# }}} 

popd
# TODO add urlview as a manual install

# {{{ TMUX PLUGIN MANAGER - TPM
[ ! -d "$HOME/.tmux/plugins/tpm" ] && git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
# }}}

# {{{ RUBY

[ -v gem ] && gem install jekyll bundler

# }}}

# {{{ Installing CURL with SFTP support

# https://github.com/moparisthebest/static-curl/releases/tag/v7.80.0 static binary

# https://andrewberls.com/blog/post/adding-sftp-support-to-curl
repos_for_compile="$HOME/repos_for_compile"
[ ! -d "$repos_for_compile" ] && mkdir "$repos_for_compile"

if [ "$distro" = "u" ]; then
    pushd "$repos_for_compile"

    # wget https://www.libssh2.org/download/libssh2-1.10.0.tar.gz
    # tar xvf libssh2-1.10.0.tar.gz
    # pushd libssh2-1.10.0
    # ./configure
    # make
    # sudo make install
    # popd
    #
    # wget https://curl.se/download/curl-7.80.0.tar.gz
    # tar xvf curl-7.80.0.tar.gz
    # pushd curl-7.80.0
    # ./configure --with-libssh2=/usr/local --with-openssl
    # make # Error
    # sudo make install
    # popd

    popd

fi

# }}}

# {{{ Cleanup
sudo apt autoclean
sudo apt autoremove
# }}}
