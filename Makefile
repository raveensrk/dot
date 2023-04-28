clean:
emacs:
	stow -R stow_my_emacs -t ~/ --no-folding
doom:
	stow -R doom_emacs -t ~/ --no-folding
	git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
	~/.emacs.d/bin/doom install
doom_sync:
	~/.emacs.d/bin/doom sync
vim_plug:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ubuntu:
	bash ./installer_scripts/ubuntu_packages.bash
vim:
	bash ./installer_scripts/vim_from_source.bash
pip:
	bash ./installer_scripts/pip_packages.bash
ctags:
	bash ./installer_scripts/ctags_from_source.bash
stow_from_source:
	bash ./installer_scripts/stow_from_source.bash
macos:
	bash ./installer_scripts/macos.bash
emacs_from_source:
	bash ./installer_scripts/emacs_from_source.bash
lazygit_linux:
	bash ./installer_scripts/lazygit.bash
fzf:
	bash ./installer_scripts/fzf.bash

tpm:
	bash ./installer_scripts/tpm.bash
bash_completion:
	bash ./installer_scripts/bash_completions.bash
yt_dlp:
	bash ./installer_scripts/yt-dlp.bash
stow_init_files:
	./stow/.scripts/,reinstall.bash
