#!/bin/bash

for dir in $(ls -A); do
    [ -d "$dir" ] && rm -rf "$dir"
done

wget -nc https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip -O ctags.zip
wget -nc https://github.com/facebook/PathPicker/archive/refs/heads/main.zip -O PathPicker.zip
wget -nc https://ftp.gnu.org/gnu/stow/stow-2.2.0.tar.gz
wget -nc https://ftp.gnu.org/gnu/texinfo/texinfo-6.8.tar.gz
wget -nc https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2
wget -nc https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz
wget -nc https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
wget -nc https://github.com/sharkdp/fd/releases/download/v8.3.0/fd-v8.3.0-i686-unknown-linux-musl.tar.gz
wget -nc https://github.com/tmux/tmux/releases/download/2.6/tmux-2.6.tar.gz
wget -nc https://ranger.github.io/ranger-stable.tar.gz
wget -nc https://github.com/scop/bash-completion/releases/download/2.11/bash-completion-2.11.tar.xz

[ ! -d ~/.packages_extracted ] && mkdir ~/.packages_extracted


# TODO should i add fzf here
