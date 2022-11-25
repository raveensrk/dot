#!/bin/bash

# {{{1 ***ENABLED*** DEBUG MODE
set -e
set -x

# {{{ Basic files and directories setup
[ ! -d "$HOME/.tmp"        ] && mkdir "$HOME/.tmp"
[ ! -d "$HOME/.vim"        ] && mkdir "$HOME/.vim"
[ ! -d "$HOME/.vim/undo"   ] && mkdir "$HOME/.vim/undo"
[ ! -d "$HOME/.vim/backup" ] && mkdir "$HOME/.vim/backup"
[ ! -d "$HOME/.vim/swap"   ] && mkdir "$HOME/.vim/swap"
[ -d "$HOME/tmp" ]        || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
[ -d "$HOME/.status" ]    || mkdir -p "$HOME/.status"
~/.scripts/,clean_up_.DS_Store.bash
# }}}
# {{{1 Stow general files
stow -R stow -t "$HOME" --no-folding
# Add sources whereever required
bash add_sources.bash "[ -f ~/.bash_aliases ] && source ~/.bash_aliases" "$HOME/.bashrc"
bash add_sources.bash "[ -f ~/.bashrc ] && source ~/.bashrc" "$HOME/.bash_login"
# {{{1 APT install Ubuntu packages
is_ubuntu=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d = -f 2)
echo is_ubuntu = "$is_ubuntu"

if [ "$is_ubuntu" = "Ubuntu" ]; then
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install -y  \
        libncurses-dev \
        flatpak \
        snap \
        snapd \
        autoconf \
        automake \
        cscope \
        curl \
        emacs \
        ffmpeg \
        ffmpegthumbnailer \
        firefox \
        git \
        gnome-software \
        gnuplot \
        htop \
        imagemagick \
        kdialog \
        kdiff3 \
        libssl-dev \
        mediainfo \
        mlocate \
        mpv \
        neofetch \
        newsboat \
        npm \
        obs-studio \
        octave \
        pandoc \
        pkg-config \
        python3 \
        python3-pip \
        qrencode \
        ranger \
        ripgrep \
        rsync \
        ruby \
        shellcheck \
        stow \
        tldr \
        urlview \
        vim \
        vim-gtk \
        x11-xserver-utils \
        yank \
        xclip


    sudo apt install gnome-software-plugin-flatpak
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    # TODO flatpak not working in ubuntu wsl
    # flatpak install flathub com.spotify.Client
    # flatpak install flathub org.mozilla.firefox
fi
# {{{1 Brew install macos packages
if [ "$is_linux" = "Darwin" ]; then
    if ! command -v brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew install \
        autoconf \
        automake \
        bat \
        curl \
        ffmpeg \
        ffmpegthumbnailer \
        gnuplot \
        htop \
        imagemagick \
        dialog \
        mediainfo \
        mpv \
        neofetch \
        newsboat \
        pandoc \
        pkg-config \
        python \
        ranger \
        ripgrep \
        ruby \
        shellcheck \
        stow \
        tldr \
        urlview \
        vim \
        yank \
        wget \
        lesspipe \
        rsync \
        grep \
        bfg \
        jq \
        gimp \
        emacs \
        cscope \
        w3m \
        mactex \
        klavaro

fi

# {{{1 Stow MACOS only packages
if [ "$is_linux" = "Darwin" ]; then
    stow -R stow_macos -t "$HOME" --no-folding
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
fi
# {{{1 Stow Linux only packages
is_linux=$(uname -a | cut -d ' ' -f 1)

if [ "$is_linux" = "Linux" ]; then
    stow -R stow_linux -t "$HOME" --no-folding
else
    echo Skipping linux stow command since this system is not linux...
fi

# {{{1 Install FZF
if [ ! -e ~/.fzf/bin/fzf ]; then
    git clone --depth 1 "git@github.com:junegunn/fzf.git" ~/.fzf
    "$HOME/.fzf/install" --all
fi

# {{{1 Install colemak
if [ "$is_linux" = "Linux" ]; then
    # https://colemak.com/Unix
    pushd ~/.tmp
    wget -nc "https://colemak.com/pub/unix/colemak-1.0.tar.gz"
    tar xvf colemak-1.0.tar.gz
    pushd colemak-1.0
    setxkbmap us; xmodmap xmodmap/xmodmap.colemak && xset r 66
    setxkbmap us -variant colemak
    popd
    popd
fi
# {{{1 Install TPM
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
    git clone "git@github.com:tmux-plugins/tpm.git" "$HOME/.tmux/plugins/tpm"
else
    echo TPM present...
fi
# {{{1 Install yt-dlp
if [ ! -e ~/.local/bin/yt-dlp ]; then
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
    chmod a+rx ~/.local/bin/yt-dlp
fi 
# {{{1 Install vim plugins and clean
vim -c "PlugInstall | PlugClean | qa"
# {{{1 Install Bash completions package
if [ ! -f ~/.local/etc/profile.d/bash_completion.sh ]; then
    pushd ~/.tmp
    wget -nc https://github.com/scop/bash-completion/releases/download/2.11/bash-completion-2.11.tar.xz
    tar xf bash-completion-2.11.tar.xz
    pushd "bash-completion-2.11"
    ./configure --prefix="$HOME/.local"
    make
    make install
    popd
    popd
    bash add_sources.bash "[ -f ~/.local/etc/profile.d/bash_completion.sh ] && source ~/.local/etc/profile.d/bash_completion.sh"  "$HOME/.bashrc"
fi 

# {{{1 Misc
# Not sure if this is required anymore
# chmod 644 "$HOME/.ssh/config"
