sudo dnf install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install -y \
    autoconf \
    automake \
    bat \
    curl \
    ffmpeg \
    ffmpegthumbnailer \
    gnuplot \
    htop \
    ImageMagick \
    kdialog \
    kdiff3 \
    mediainfo \
    plocate \
    mpv \
    neofetch \
    newsboat \
    obs-studio \
    openssl-devel \
    pandoc \
    pkg-config \
    python \
    python3 \
    python3-pip \
    ranger \
    ripgrep \
    ruby \
    ShellCheck \
    stow \
    tldr \
    urlview \
    vim \
    vim-X11 \
    yank \
    rsync \
    jq \
    gimp \
    emacs \
    ncurses-devel-6.2-9.20210508.fc36.x86_64 \
    libX11-devel-1.7.3.1-2.fc36.x86_64  \
    libXt-devel \
    exa \
    cscope \
    gnome-software \
    git \
    hg \
    octave \
    qrencode \
    npm \
    xset \
    google-chrome \


    sudo dnf install touchegg -y
# You may also need to manually start the service
sudo systemctl start touchegg
sudo systemctl enable touchegg
sudo dnf groupinstall i3-desktop-environment
npm install --global prettier @prettier/plugin-lua @prettier/plugin-php prettier-plugin-solidity prettier-plugin-svelte prettier-plugin-toml
