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
