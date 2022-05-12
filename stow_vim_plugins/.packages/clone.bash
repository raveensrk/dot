#!/bin/bash

set -e

# Wget operates in quiet mode

get () {
    wget -qnc $@
}

get https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip -O ctags.zip
get https://github.com/facebook/PathPicker/archive/refs/heads/main.zip -O PathPicker.zip
get https://ftp.gnu.org/gnu/stow/stow-2.2.0.tar.gz
get https://ftp.gnu.org/gnu/texinfo/texinfo-6.8.tar.gz
get https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2
get https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz
get https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
get https://github.com/sharkdp/fd/releases/download/v8.3.0/fd-v8.3.0-i686-unknown-linux-musl.tar.gz
get https://github.com/tmux/tmux/releases/download/2.6/tmux-2.6.tar.gz
get https://ranger.github.io/ranger-stable.tar.gz
get https://github.com/scop/bash-completion/releases/download/2.11/bash-completion-2.11.tar.xz
get https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz

for f in *.tar*; do
    tar xf "$f"
done

for f in *.zip; do
    unzip -qu "$f"
done

if [ "$1" = "--rebuild" ]; then
    rebuild="Y"
else
    rebuild="n"
fi

if [ "$rebuild" = "Y" ]; then

    echo -e "${BLUE}Do you want to install libevent? [Y/n]:${NC}"
    read -r choice
    if [ "$choice" = "Y" ]; then
        tar xf libevent-2.1.12-stable.tar.gz
        pushd libevent-2.1.12-stable || exit 2
        ./configure --prefix="$HOME/.local" --enable-shared
        make -j
        make install -j
        popd || exit 2
        rm -rf libevent-2.1.12-stable
    fi 
    unset choice

    echo -e "${BLUE}Do you want to install tmux? [Y/n]:${NC}"
    read -r choice
    if [ "$choice" = "Y" ]; then
        tar xf tmux-2.6.tar.gz
        # https://github.com/tmux/tmux/wiki/Installing#building-dependencies
        pushd tmux-2.6 || exit 2
        PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig ./configure --prefix="$HOME/.local"
        make -j
        make install -j
        popd || exit 2
        rm -rf tmux-2.6
    fi 
    unset choice

    echo -e "${BLUE}Do you want to install vim82? [Y/n]:${NC}"
    read -r choice
    if [ "$choice" = "Y" ]; then
        tar xf vim-8.2.tar.bz2
        pushd vim82 || exit 2
        ./configure --prefix="$HOME/.local" # defaults to /usr/local
        make -j
        make install -j
        popd || exit 2
        rm -rf vim82
    fi 
    unset choice

    echo -e "${BLUE}Do you want to install ctags? [Y/n]:${NC}"
    read -r choice
    if [ "$choice" = "Y" ]; then
        unzip -u ctags.zip
        pushd ctags || exit 2
        ./autogen.sh
        ./configure --prefix="$HOME/.local" # defaults to /usr/local
        make -j
        make install -j # may require extra privileges depending on where to install
        popd || exit 2
        rm -rf ctags
    fi 
    unset choice

    echo -e "${BLUE}INSTALL BASH Completions? [Y/n] [Default n]:${NC}"
    read -r choice
    if [ "$choice" = "Y" ]; then
        tar -xf bash-completion-2.11.tar.xz
        pushd ~/.packages_extracted/bash-completion-2.11 || exit 2
        autoreconf -i  # if not installing from prepared release tarball
        ./configure --prefix="$HOME/.local"
        make -j         # GNU make required
        make check -j     # optional, requires python3 with pytest >= 3.6, pexpect
        make install -j   # as root
        popd || exit 2
        rm -rf bash-completion-2.11
    fi 
    unset choice

    # TODO add urlview as a manual install
    # TODO install stow manual
    # TODO Install EMACS instructions

fi # rebuild

unset rebuild

exit 0
