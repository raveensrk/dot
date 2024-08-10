set formatprg=shfmt
set nospell
command! -buffer Lint !shellcheck %
