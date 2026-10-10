#!/bin/bash
# Install the macOS brew and MacPorts packages this machine uses.
#
# Reads nothing. Writes through brew and port. Needs a network, and sudo for port.
# exit: 0 for help, otherwise the install command's status

case "${1:-}" in
	-h|--help) sed -n '2s/^# \{0,1\}//p' "$0"; exit 0 ;;
	help) sed -n '2,/^[^#]/s/^# \{0,1\}//p' "$0"; exit 0 ;;
esac

xcode-select --install

if ! command -v brew; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# export HOMEBREW_NO_AUTO_UPDATE=1

# brew update
# brew upgrade

packages=(
	autoconf
	automake
	bash-completion@2
	bat
	cscope
	curl
	cyrus-sasl
	dialog
	ffmpeg
	ffmpegthumbnailer
	findutils
	fortune
	gnuplot
	graphicsmagick
	grep
	gawk
	htop
	iina
	imagemagick
	ispell
	jq
	lazygit
	lesspipe
	lolcat
	# mactex
	mediainfo
	mdformat
	neofetch
	newsboat
	pandoc
	pkg-config
	python
	ranger
	ripgrep
	rsync
	shellcheck
	shfmt
	sqlite
	tldr
	universal-ctags
	up
	urlview
	w3m
	wget
	dict
	direnv
	entr
	mpv
	zoxide
)

brew install ${packages[*]}

# https://www.macports.org/install.php

sudo port install gtkwave gtk2 sqlite3-tcl
sudo port select --set pygments py312-pygments


