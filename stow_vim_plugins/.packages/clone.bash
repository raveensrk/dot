#!/bin/bash

set -e

[ -d ctags ] && rm -vrf ctags
[ -d PathPicker ] &&	rm -vrf PathPicker
[ -d fd-v8.3.0-i686-unknown-linux-musl ] &&	rm -vrf fd-v8.3.0-i686-unknown-linux-musl
[ -d libevent-2.1.12-stable ] &&	rm -vrf libevent-2.1.12-stable
[ -d ranger-1.9.3 ] &&	rm -vrf ranger-1.9.3
[ -d shellcheck-stable ] &&	rm -vrf shellcheck-stable
[ -d stow-2.2.0 ] &&	rm -vrf stow-2.2.0
[ -d texinfo-6.8 ] &&	rm -vrf texinfo-6.8
[ -d tmux-2.6 ] &&	rm -vrf tmux-2.6
[ -d vim ] &&	rm -vrf vim

git clone "https://github.com/universal-ctags/ctags.git"
git clone git@github.com:facebook/PathPicker.git
wget https://ftp.gnu.org/gnu/stow/stow-2.2.0.tar.gz
wget https://ftp.gnu.org/gnu/texinfo/texinfo-6.8.tar.gz
wget https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2
wget https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz
wget https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
wget https://github.com/sharkdp/fd/releases/download/v8.3.0/fd-v8.3.0-i686-unknown-linux-musl.tar.gz
wget https://github.com/tmux/tmux/releases/download/2.6/tmux-2.6.tar.gz
wget https://ranger.github.io/ranger-stable.tar.gz

for f in *.tar*; do
    tar xf "$f"
done

rm -v ./*.tar*

# TODO should i add fzf here
