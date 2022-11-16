[ -d "$HOME/tmp" ] || mkdir "$HOME/tmp"
[ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin"
[ -d "$HOME/.status" ] || mkdir -p "$HOME/.status"
bash add_sources.bash "[ -f ~/.bash_aliases ] && source ~/.bash_aliases" "$HOME/.bashrc"
bash add_sources.bash "[ -f ~/.bashrc ] && source ~/.bashrc" "$HOME/.bash_login"
stow -R stow -t "$HOME" --no-folding

# Not sure if this is required anymore
# chmod 644 "$HOME/.ssh/config"

stow -R doom_emacs -t "$HOME" --no-folding
