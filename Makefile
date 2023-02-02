emacs_install:
	stow -R stow_my_emacs -t ~/ --no-folding
emacs_uninstall:
	rm -rf ~/.doom.d ~/.emacs.d
doom_install:
	stow -R doom_emacs -t ~/ --no-folding
	git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
	~/.emacs.d/bin/doom install
doom_sync:
	~/.emacs.d/bin/doom sync
vim_plug:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
upgrade_ubuntu:
	bash ./installer_scripts/install_ubuntu_packages.bash
todo.txt:
	bash ./installer_scripts/todo.txt.bash
vim:
	bash ./installer_scripts/install_vim_from_source.bash
pip:
	bash ./installer_scripts/pip_packages.bash
ctags:
	bash ./installer_scripts/install_ctags_from_source.bash
clean:
stow:
	bash ./installer_scripts/install_stow_from_source.bash
