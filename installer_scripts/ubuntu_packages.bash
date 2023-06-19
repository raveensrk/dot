sudo apt update -y
sudo apt upgrade -y
sudo apt install -y  \
    x11-xkb-utils \
    libreoffice \
    zathura `# PDF viewer` \
    eog `# Eyo of gnome image viewer` \
    libdbus-glib-1-dev  `# This is to use firefox binary in wsl 2` \
    libncurses-dev \
    flatpak \
    snap \
    snapd \
    autoconf \
    automake \
    cscope \
    curl \
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
    python2 \
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
    xclip \
    gifsicle \
    bat \
    bc \
    texlive


sudo apt install -y gnome-software-plugin-flatpak
sudo apt autoremove -y
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# TODO flatpak not working in ubuntu wsl
# flatpak install flathub com.spotify.Client
# flatpak install flathub org.mozilla.firefox

