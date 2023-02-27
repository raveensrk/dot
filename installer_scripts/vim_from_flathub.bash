  pushd ~/.tmp
  wget -nc "https://dl.flathub.org/repo/appstream/org.vim.Vim.flatpakref"
  flatpak install --user org.vim.Vim.flatpakref
  popd
