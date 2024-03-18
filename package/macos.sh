#!/bin/bash

xcode-select --install

if ! command -v brew; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew update

packages=(
	autoconf
	automake
	# basictex
	bat
	cscope
	curl
	dialog
    dict
	ffmpeg
	ffmpegthumbnailer
	findutils
	fortune
	gnuplot
	graphicsmagick
	grep
	htop
	iina
	imagemagick
	ispell
	jq
	lazygit
	lesspipe
	lolcat
    mpv
	mactex
	mediainfo
	neofetch
	newsboat
	pandoc
	pkg-config
	poppler
	python
	ranger
	ripgrep
	rsync
	ruby
	shellcheck
	sqlite
	tldr
	neomutt
	universal-ctags
	up
	urlview
	# vim
	w3m
	wget
	shfmt
	cyrus-sasl
)

export HOMEBREW_NO_AUTO_UPDATE=1

brew install ${packages[@]}
