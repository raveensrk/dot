#!/bin/bash

xcode-select --install

if ! command -v brew; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew update

packages=(
	autoconf
	automake
	basictex
	bat
	cscope
	curl
	dialog
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

for package in "${packages[@]}"; do
	if brew list --versions "$package"; then
		echo "Package $package, is already installed..."
	else
		if brew install --cask "$package"; then
			echo "Package $package, installed as cask..."
		else
			brew install "$package"
			echo "Package $package, installed as not cask..."
		fi
	fi
done

