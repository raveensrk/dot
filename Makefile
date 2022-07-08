.ONESHELL:
	# Applies to every targets in the file! By default every command
	# alls a subshell this prevents that
	SHELL = /usr/bin/bash

clean:
	rm -rfv ./tmp/* ./tmp/.*

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

stow_basic:
	bash add_sources.bash "[ -f ~/.bash_aliases ] && source ~/.bash_aliases"
	stow -R stow -t "$$HOME" --no-folding

stow_wsl2:
	stow -R stow_wsl2_scripts -t "$$HOME" --no-folding

stow_macos:
	stow -R stow_macos -t "$$HOME" --no-folding

stow_linux:
	stow -R stow_linux -t "$$HOME" --no-folding

stow_vim_plugins:
	stow -R stow_vim_plugins -t "$$HOME"

install_plugins_for_vim_and_emacs:
	vim -c "PlugInstall | PlugClean | qa"
	emacs -nw -f my-package-refresh-and-install-selected-packages --kill


upgrade_macos:
	bash upgrade_macos.bash

upgrade_fedora:
	bash upgrade_fedora.bash

upgrade_ubuntu_18:
	bash upgrade_ubuntu.bash  packages_list_ubuntu.txt

upgrade_ubuntu_20:
	bash upgrade_ubuntu.bash packages_list_ubuntu_20.txt

install_vim:
	bash install_vim.bash

install_yt-dlp:
	curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
	chmod a+rx ~/.local/bin/yt-dlp

install_tpm:
	git clone "git@github.com:tmux-plugins/tpm.git" "$HOME/.tmux/plugins/tpm"

uninstall_tpm:
	rm -vrf "$HOME/.tmux/plugins/tpm"

install_fzf:
	bash install_fzf.bash

install_bash_completions:
	bash install_bash_completions.bash

uninstall_bash_completions:
	cd stow_vim_plugins/.packages/bash-completion-2.11
	make uninstall
	cd ..
	rm -rf bash-completion-2.11
	rm bash-completion-2.11.tar.xz

install_basic: stow_basic install_vim install_bash_completions

uninstall_all: uninstall_bash_completions
