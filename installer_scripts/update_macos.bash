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
