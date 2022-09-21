#!/opt/homebrew/bin/bash

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


sudo dnf install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install $(xargs < ./packages_list_fedora.txt) -y
sudo dnf install touchegg -y
# You may also need to manually start the service
sudo systemctl start touchegg
sudo systemctl enable touchegg

npm install --global prettier @prettier/plugin-lua @prettier/plugin-php prettier-plugin-solidity prettier-plugin-svelte prettier-plugin-toml
