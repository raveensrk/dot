[ ! -d $HOME/.tmp        ] && mkdir "$HOME/.tmp"
[ ! -d $HOME/.vim        ] && mkdir "$HOME/.vim"
[ ! -d $HOME/.vim/undo   ] && mkdir "$HOME/.vim/undo"
[ ! -d $HOME/.vim/backup ] && mkdir "$HOME/.vim/backup"
[ ! -d $HOME/.vim/swap   ] && mkdir "$HOME/.vim/swap"
[ -d "$HOME/tmp" ] || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
[ -d "$HOME/.status" ] || mkdir -p "$HOME/.status"
bash add_sources.bash "[ -f ~/.bash_aliases ] && source ~/.bash_aliases" "$HOME/.bashrc"
bash add_sources.bash "[ -f ~/.bashrc ] && source ~/.bashrc" "$HOME/.bash_login"
stow -R stow -t "$HOME" --no-folding

# Not sure if this is required anymore
# chmod 644 "$HOME/.ssh/config"

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

if [ "$is_ubuntu" = "Ubuntu" ] || [ "$is_linux" = "Darwin" ]; then
    stow -R doom_emacs -t "$HOME" --no-folding
    if [ ! -e ~/.emacs.d/bin/doom ]; then
        git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
        ~/.emacs.d/bin/doom install
        ~/.emacs.d/bin/doom sync
    else
        echo Doom exists...
    fi
else
    stow -R stow_my_emacs -t "$HOME" --no-folding
fi
