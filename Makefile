.ONESHELL:
	# Applies to every targets in the file! By default every command
	# alls a subshell this prevents that
	# art
	SHELL = /usr/bin/bash -x

clean:
	rm -rfv ./tmp

install_colemak:
	# https://colemak.com/Unix
	mkdir tmp
	cd tmp
	wget -nc "https://colemak.com/pub/unix/colemak-1.0.tar.gz"
	tar xvf colemak-1.0.tar.gz
	cd colemak-1.0
	setxkbmap us; xmodmap xmodmap/xmodmap.colemak && xset r 66

uninstall_colemak:
	setxkbmap us; xmodmap xmodmap/xmodmap.colemak && xset r 66


install_vim_from_flathub:
	mkdir tmp
	cd tmp
	wget -nc "https://dl.flathub.org/repo/appstream/org.vim.Vim.flatpakref"
	flatpak install --user org.vim.Vim.flatpakref

install_git:
	mkdir tmp
	cd tmp
	wget -nc https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz
	tar xf git-2.9.5.tar.gz
	cd git-2.9.5
	./configure --prefix=$$HOME/.local
	make -j
	make install

stow:
	bash add_sources.bash 

upgrade_macos:
	bash upgrade_macos.bash

upgrade_fedora:
	bash upgrade_fedora.bash

upgrade_ubuntu_18:
	bash upgrade_ubuntu.bash  packages_list_ubuntu.txt

upgrade_ubuntu_20:
	bash upgrade_ubuntu.bash packages_list_ubuntu_20.txt

setup_vim:
    [ ! -d "$HOME/.vim/undo" ] && mkdir -p "$HOME/.vim/undo"
    [ ! -d "$HOME/.vim/backup" ] && mkdir -p "$HOME/.vim/backup"
    [ ! -d "$HOME/.vim/swap" ] && mkdir -p "$HOME/.vim/swap"
