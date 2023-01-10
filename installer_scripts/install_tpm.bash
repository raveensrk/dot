# {{{1 Install TPM
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
    git clone "git@github.com:tmux-plugins/tpm.git" "$HOME/.tmux/plugins/tpm"
else
    echo TPM present...
fi
