#!/usr/bin/env bash

# Emacs install.
#
# Config lives in config/emacs/ and is tracked. Emacs loads it through
# ~/.emacs.d/init.el, which is a one-line loader - the same pattern as vim,
# where bashrc sets MYVIMRC=$DOT/config/vimrc.
#
#   ~/.emacs.d/init.el  ->  (load "~/dot/config/emacs/init.el")
#
# ~/.emacs.d/ itself stays untracked. straight.el clones every package into
# ~/.emacs.d/straight/, and Emacs writes saveplace, eln-cache and autosaves
# there. None of that belongs in git.
#
# config/emacs/init.el is a straight.el + use-package setup with about 70
# packages. The first start downloads straight.el and then every package, so
# expect a long first run and a working network connection.

set -PCeuo pipefail
IFS=$'\n\t'

if [[ "$(uname -s)" == "Darwin" ]]; then
	brew install --cask emacs-app
else
	sudo apt install emacs
fi

# First start bootstraps straight.el and installs the packages.
# Run it once by hand so the download is visible.
emacs --version
