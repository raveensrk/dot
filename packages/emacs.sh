#!/usr/bin/env bash
# Build GNU Emacs from a release tarball and install it.
#
# macOS: Cocoa (NS) GUI, installed to ~/Applications/My_Apps/Emacs.app.
#        Build deps come from Homebrew.
# Linux: GTK 3 GUI, installed under ~/.local (prefix), like packages/vim.sh.
#        Build deps come from apt.
#
# Both builds turn on native compilation (libgccjit, every bundled .el
# compiled ahead of time), tree-sitter and GnuTLS.
#
# The tarball comes from ftpmirror.gnu.org and is checked against its .sig
# with the GNU keyring (gnu-keyring.gpg), read by gpgv from that file, so your
# own gpg keyring is never touched.
#
# Source and build tree: ~/tmp/emacs_build/emacs-<version>. A second run
# reuses the downloaded tarball.
#
# Command line wrappers, not symlinks: on macOS ~/.local/bin/emacs and
# ~/.local/bin/emacsclient are two-line scripts that exec the binaries inside
# the app. ~/.local/bin is on PATH through config/bashrc.
#
# --global installs for every user instead: /Applications/Emacs.app and
# wrappers in /usr/local/bin on macOS, prefix /usr/local on Linux. It uses
# sudo only where the target is not writable by you. This is the one
# deliberate exception to the ~/Applications/My_Apps rule.
#
# --uninstall undoes an install made the same way (add --global for a
# global one). macOS: the app, the two wrappers and ~/tmp/emacs_build go to
# the Trash. Linux: make uninstall in the build tree (a permanent delete,
# named before it runs), then the build tree goes to the Trash. It lists
# everything first and asks once. ~/.emacs.d is never touched.
#
# Reinstall: the new Emacs.app is synced over the old one in place
# (rsync --delete), so a Dock tile or Open With entry keeps pointing at it.
# Quit Emacs first.
#
# No init file is installed. Emacs starts with its defaults.

set -Eeuo pipefail
IFS=$'\n\t'

prog=emacs.sh
version=31.1
jobs=""
dry=0
global=0
uninstall=0

short_help() {
	cat <<EOF
Usage: $prog [--version|-v VER] [--jobs|-j N] [--global|-g] [--dry-run|-n]
       $prog --uninstall|-u [--global|-g] [--version|-v VER] [--dry-run|-n]
       $prog help | -h | --help

Build GNU Emacs from source and install it.
macOS: ~/Applications/My_Apps/Emacs.app. Linux: ~/.local.
With --global: /Applications/Emacs.app and /usr/local/bin (macOS),
/usr/local (Linux).

Options:
  --version, -v VER   Emacs release to build (default: $version)
  --jobs, -j N        parallel make jobs (default: CPU count)
  --global, -g        install for every user; sudo where needed
  --uninstall, -u     remove what this script installed (Trash first)
  --dry-run, -n       print every step, change nothing
  -h, --help          this help
  help                long help

Example:
  $prog --dry-run
EOF
}

long_help() {
	short_help
	cat <<'EOF'

Steps:
  1. Install build deps (brew on macOS, apt on Linux).
  2. Download emacs-VER.tar.xz and .sig to ~/tmp/emacs_build, verify with
     the GNU keyring.
  3. ./configure with native compilation, tree-sitter and GnuTLS
     (--with-ns on macOS, --with-pgtk on Linux).
  4. make -j N, then make install.
  5. macOS: sync nextstep/Emacs.app into ~/Applications/My_Apps/Emacs.app,
     write site-start.el so native compilation finds libgcc at run time,
     and write the emacs and emacsclient wrappers in ~/.local/bin.
     With --global: /Applications/Emacs.app and /usr/local/bin.

--global on Linux sets the prefix to /usr/local. Either way, sudo is used
only for a target directory you cannot write to, and asks for your
password then.

Uninstall:
  macOS: lists the app, ~/.local/bin/emacs, ~/.local/bin/emacsclient and
  ~/tmp/emacs_build (or the --global paths), asks once, then moves them to
  the Trash. Restore from Finder > Trash.
  Linux: runs make uninstall in ~/tmp/emacs_build/emacs-VER, which deletes
  the installed files for good, then moves the build tree to the Trash.
  Pass the same --version and --global the install used.
  ~/.emacs.d is left alone.

Quit Emacs before a reinstall. The first build takes 10 to 30 minutes:
native compilation compiles every bundled .el file.

Exit 0 on success, 1 on any failure, with "emacs.sh: <message>" on stderr.
EOF
}

die() {
	echo "$prog: $*" >&2
	exit 1
}

# priv is empty, or (sudo) for a target you cannot write to.
priv=()

# Set priv for a target path: sudo when its nearest existing parent is not
# writable by you.
priv_for() {
	local dir=$1
	while [[ ! -e $dir ]]; do
		dir=$(dirname "$dir")
	done
	if [[ -w $dir ]]; then
		priv=()
	else
		priv=(sudo)
	fi
}

# Run a command, or only print it under --dry-run.
run() {
	local IFS=' '
	echo "+ $*"
	if ((dry == 0)); then
		"$@"
	fi
}

# cd, or only print it under --dry-run.
cd_or_dry() {
	echo "+ cd $1"
	if ((dry == 0)); then
		cd "$1"
	fi
}

# Write stdin to a file, or only print the target under --dry-run.
write_file() {
	local path=$1
	local IFS=' '
	echo "+ ${priv[*]+${priv[*]} }write $path"
	if ((dry == 0)); then
		${priv[@]+"${priv[@]}"} tee "$path" >/dev/null
	else
		cat >/dev/null
	fi
}

while (($#)); do
	case $1 in
	-h | --help)
		short_help
		exit 0
		;;
	help)
		long_help
		exit 0
		;;
	-v | --version)
		[[ $# -ge 2 ]] || die "$1 needs a value"
		version=$2
		shift 2
		;;
	-j | --jobs)
		[[ $# -ge 2 && $2 =~ ^[1-9][0-9]*$ ]] || die "$1 needs a positive number"
		jobs=$2
		shift 2
		;;
	-g | --global)
		global=1
		shift
		;;
	-u | --uninstall)
		uninstall=1
		shift
		;;
	-n | --dry-run)
		dry=1
		shift
		;;
	*)
		die "unknown argument: $1 (see $prog --help)"
		;;
	esac
done

[[ $version =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || die "bad version: $version"

os=$(uname -s)
case $os in
Darwin) jobs=${jobs:-$(sysctl -n hw.ncpu)} ;;
Linux) jobs=${jobs:-$(nproc)} ;;
*) die "unsupported OS: $os" ;;
esac

build_root=$HOME/tmp/emacs_build
tarball=emacs-$version.tar.xz
src=$build_root/emacs-$version
url=https://ftpmirror.gnu.org/emacs/$tarball
keyring_url=https://ftp.gnu.org/gnu/gnu-keyring.gpg

# Install targets. macOS uses app_dir and bin_dir, Linux uses prefix.
if ((global)); then
	app_dir=/Applications # lint:ignore - --global asks for this on purpose
	bin_dir=/usr/local/bin
	prefix=/usr/local
else
	app_dir=$HOME/Applications/My_Apps
	bin_dir=$HOME/.local/bin
	prefix=$HOME/.local
fi
app=$app_dir/Emacs.app

# Move paths to the Trash, with sudo for one you cannot write to.
to_trash() {
	local path
	for path in "$@"; do
		priv_for "$(dirname "$path")"
		if [[ $os == Darwin ]]; then
			run ${priv[@]+"${priv[@]}"} trash "$path"
		else
			run ${priv[@]+"${priv[@]}"} gio trash "$path"
		fi
	done
}

if ((uninstall)); then
	if [[ $os == Darwin ]] && pgrep -f "$app/Contents/MacOS/Emacs" >/dev/null; then
		die "Emacs is running from $app; quit it and run again"
	fi
	targets=()
	if [[ $os == Darwin ]]; then
		for path in "$app" "$bin_dir/emacs" "$bin_dir/emacsclient"; do
			if [[ -e $path ]]; then targets+=("$path"); fi
		done
	else
		[[ -f $src/Makefile ]] ||
			die "no configured build tree at $src; make uninstall needs it (pass the --version you installed)"
		echo "make uninstall in $src deletes Emacs from $prefix for good."
	fi
	if [[ -e $build_root ]]; then targets+=("$build_root"); fi
	if ((${#targets[@]} == 0)) && [[ $os == Darwin ]]; then
		echo "Nothing to remove: no Emacs from this script found."
		exit 0
	fi
	echo "To the Trash:"
	printf '  %s\n' "${targets[@]}"
	if ((dry == 0)); then
		read -r -p "Go ahead? [y/N] " answer || answer=""
		[[ $answer == [yY]* ]] || die "cancelled, nothing removed"
	fi
	if [[ $os != Darwin ]]; then
		command -v gio >/dev/null || die "gio not found; it moves files to the Trash"
		cd_or_dry "$src"
		priv_for "$prefix"
		run ${priv[@]+"${priv[@]}"} make uninstall
		cd_or_dry "$HOME"
	fi
	to_trash "${targets[@]}"
	if ((dry)); then
		echo "Dry run: nothing changed."
	else
		echo "Uninstalled. ~/.emacs.d left alone."
	fi
	exit 0
fi

# 1. Build deps.
configure_flags=(
	--with-native-compilation=aot
	--with-tree-sitter
	--with-gnutls
	--without-compress-install
)

if [[ $os == Darwin ]]; then
	command -v brew >/dev/null || die "Homebrew not found"
	run brew install pkgconf gnutls libgccjit gcc tree-sitter texinfo \
		librsvg little-cms2 webp sqlite gmp gnupg
	brew_prefix=$(brew --prefix)
	gccjit=$brew_prefix/opt/libgccjit
	gcc_major=$(brew list --versions gcc 2>/dev/null | awk '{print $2}' | cut -d. -f1)
	[[ -n $gcc_major || $dry == 1 ]] || die "gcc not installed"
	gcc_lib=$brew_prefix/opt/gcc/lib/gcc/current
	export CFLAGS="-O2 -I$gccjit/include"
	export LDFLAGS="-L$gccjit/lib/gcc/current -Wl,-rpath,$gccjit/lib/gcc/current"
	darwin_major=$(uname -r | cut -d. -f1)
	export LIBRARY_PATH="$gcc_lib:$gcc_lib/gcc/aarch64-apple-darwin$darwin_major/$gcc_major"
	configure_flags+=(--with-ns)
else
	command -v apt-get >/dev/null || die "apt-get not found"
	gcc_major=$(gcc -dumpversion | cut -d. -f1)
	run sudo apt-get install -y build-essential pkg-config texinfo gnupg \
		libgtk-3-dev libgnutls28-dev "libgccjit-$gcc_major-dev" \
		libtree-sitter-dev libxml2-dev libjpeg-dev libpng-dev libgif-dev \
		libtiff-dev librsvg2-dev libwebp-dev libsqlite3-dev libncurses-dev \
		liblcms2-dev libgmp-dev
	configure_flags+=(--with-pgtk "--prefix=$prefix")
fi

# 2. Download and verify.
run mkdir -p "$build_root"
cd_or_dry "$build_root"

if [[ ! -f $build_root/$tarball ]]; then
	run curl -fL --max-time 600 -o "$tarball.part" "$url"
	run mv "$tarball.part" "$tarball"
fi
run curl -fsSL --max-time 60 -o "$tarball.sig" "$url.sig"
run curl -fsSL --max-time 60 -o gnu-keyring.gpg "$keyring_url"
# gpgv, not gpg: gpg 2.4 with use-keyboxd ignores --keyring.
run gpgv --keyring "$build_root/gnu-keyring.gpg" "$tarball.sig" "$tarball"

run rm -rf "$src"
run tar -xf "$tarball"
cd_or_dry "$src"

# 3 and 4. Configure, build, install.
run ./configure "${configure_flags[@]}"
run make -j "$jobs"
# On macOS make install fills nextstep/Emacs.app inside the build tree.
if [[ $os != Darwin ]]; then
	priv_for "$prefix"
fi
run ${priv[@]+"${priv[@]}"} make install

# 5. Linux is done: make install wrote into the prefix.
if [[ $os != Darwin ]]; then
	echo "Installed: $prefix/bin/emacs"
	exit 0
fi

if pgrep -f "$app/Contents/MacOS/Emacs" >/dev/null; then
	die "Emacs is running from $app; quit it and run again"
fi

priv_for "$app_dir"
run ${priv[@]+"${priv[@]}"} mkdir -p "$app_dir"
run ${priv[@]+"${priv[@]}"} rsync -a --delete "$src/nextstep/Emacs.app/" "$app/"

# Native compilation of packages installed later runs at run time, and a
# GUI launch does not inherit LIBRARY_PATH from the shell.
write_file "$app/Contents/Resources/site-lisp/site-start.el" <<EOF
;;; site-start.el --- written by ~/dot/packages/emacs.sh  -*- lexical-binding: t -*-
;; Lets native compilation find libgcc when Emacs is started from Finder.
(setenv "LIBRARY_PATH" "$LIBRARY_PATH")
EOF

priv_for "$bin_dir"
run ${priv[@]+"${priv[@]}"} mkdir -p "$bin_dir"
write_file "$bin_dir/emacs" <<EOF
#!/usr/bin/env bash
exec "$app/Contents/MacOS/Emacs" "\$@"
EOF
run ${priv[@]+"${priv[@]}"} chmod +x "$bin_dir/emacs"

write_file "$bin_dir/emacsclient" <<EOF
#!/usr/bin/env bash
exec "$app/Contents/MacOS/bin/emacsclient" "\$@"
EOF
run ${priv[@]+"${priv[@]}"} chmod +x "$bin_dir/emacsclient"

if ((dry)); then
	echo "Dry run: nothing changed. Would install $app"
else
	echo "Installed: $app"
fi
