# Lazygit

Git TUI. Config lives in [config/lazygit.yml](../config/lazygit.yml).

`LG_CONFIG_FILE` is set in [config/bashrc](../config/bashrc) so a plain
`lazygit` load uses that file. Alias: `lg`.

```sh
export LG_CONFIG_FILE=$DOT/config/lazygit.yml
alias lg=lazygit
```

Install: [packages/lazygit.sh](../packages/lazygit.sh) (Linux) or `brew install
lazygit` via [packages/macos.sh](../packages/macos.sh).
Tests: [tests/test_lazygit.py](../tests/test_lazygit.py).

## Commit with pi

On the Files tab, `C` runs [config/lazygit_pi_commit.sh](../config/lazygit_pi_commit.sh):

1. Abort if nothing is staged.
2. Pipe `git diff --cached` into `pi -p` (no tools, no session).
3. Open the git editor with that message so you can edit before it lands.

## Citations

- Lazygit config: <https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md>
- Custom commands: <https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md>
- `LG_CONFIG_FILE` can be a comma-separated list; later files override earlier ones.
