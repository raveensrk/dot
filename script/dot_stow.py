#!/usr/bin/env python3
"""Shared GNU Stow engine for the dotfiles repo.

Mappings live in PACKAGES: package name -> (source dir inside the repo,
target dir inside $HOME). Stow links every entry of the source dir into the
target dir with `stow -d <source parent> -t <target> <source name>`.

install.py and uninstall.py are thin CLIs over plan_install/install and
plan_uninstall/uninstall. Dry-run planning never touches the filesystem;
apply is explicit.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import time
from dataclasses import dataclass, field
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

# package name: (source dir inside the repo, target dir inside $HOME)
PACKAGES: dict[str, tuple[str, str]] = {
    "pi": ("config/pi", ".pi/agent"),
}

LOCAL_IGNORE_FILE = ".stow-local-ignore"
GLOBAL_IGNORE_FILE = ".stow-global-ignore"

# Stow's built-in ignore list, used when the package has no local ignore file.
# Keep in sync with the copy in config/pi/.stow-local-ignore.
DEFAULT_IGNORE = (
    r"RCS",
    r".+,v",
    r"CVS",
    r"\.\#.+",
    r"\.cvsignore",
    r"\.svn",
    r"_darcs",
    r"\.hg",
    r"\.git",
    r"\.gitignore",
    r"\.gitmodules",
    r".+~",
    r"\#.*\#",
    r"^/README.*",
    r"^/LICENSE.*",
    r"^/COPYING",
)

LABELS = {
    "link": "LINK",
    "replace": "REPLACE",
    "backup": "BACKUP",
    "adopt": "ADOPT",
    "remove": "REMOVE",
    "conflict": "CONFLICT",
    "skip": "SKIP",
}
ORDER = ("link", "replace", "backup", "adopt", "remove", "conflict", "skip")


class StowError(RuntimeError):
    """stow could not run or exited non-zero."""


class StowMissing(StowError):
    """GNU stow is not on PATH."""


class ConflictError(StowError):
    """Real files/symlinks block stowing and no resolution flag was given."""

    def __init__(self, plan: "Plan"):
        super().__init__(f"{plan.package}: {len(plan.conflicts)} conflict(s)")
        self.plan = plan


@dataclass(frozen=True)
class Package:
    name: str
    source: Path
    target: Path


@dataclass
class Action:
    kind: str
    target: Path
    source: Path | None = None


@dataclass
class Plan:
    package: str
    source: Path
    target: Path
    actions: list[Action] = field(default_factory=list)

    def by_kind(self, kind: str) -> list[Action]:
        return [action for action in self.actions if action.kind == kind]

    @property
    def conflicts(self) -> list[Action]:
        return self.by_kind("conflict")

    @property
    def changes(self) -> list[Action]:
        return [action for action in self.actions if action.kind != "skip"]


def resolve(
    names: list[str] | tuple[str, ...] = (),
    repo: Path = REPO,
    home: Path | None = None,
) -> dict[str, Package]:
    """Resolve package names to absolute paths. No names means every package."""
    unknown = sorted(set(names) - set(PACKAGES))
    if unknown:
        raise KeyError(f"unknown package(s): {', '.join(unknown)}")
    home = Path(home) if home is not None else Path.home()
    chosen = list(names) if names else list(PACKAGES)
    return {
        name: Package(name, repo / PACKAGES[name][0], home / PACKAGES[name][1])
        for name in chosen
    }


def short(path: Path) -> str:
    """Render a path relative to $HOME when possible."""
    try:
        return "~/" + str(path.relative_to(Path.home()))
    except ValueError:
        return str(path)


def format_plan(plan: Plan, *, applied: bool) -> list[str]:
    """House-style lines for one package's plan."""
    counts = {kind: len(plan.by_kind(kind)) for kind in ORDER}
    summary = ", ".join(f"{counts[kind]} {kind}" for kind in ORDER if counts[kind])
    state = "applied" if applied else "dry-run"
    lines = [f"`-- {plan.package}: {summary or 'nothing to do'} ({state})"]
    for kind in ORDER:
        for action in plan.by_kind(kind):
            line = f"|-- [{LABELS[kind]}] {short(action.target)}"
            if kind in ("link", "adopt") and action.source is not None:
                line += f" -> {short(action.source)}"
            elif kind == "replace":
                line += " (absolute -> relative)"
            elif kind == "backup":
                line += " -> *.bak.<timestamp>"
            elif kind == "conflict":
                line += " (exists; use --backup or --adopt)"
            lines.append(line)
    if not applied and plan.changes:
        lines.append("`-- pass --apply to make these changes")
    return lines


def _parse_ignore_file(path: Path) -> list[str]:
    """Parse an ignore file the way Stow.pm does: trim, skip comments, then
    unescape \\#. Patterns containing '/' match full paths; the rest match
    basenames."""
    patterns = []
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        line = re.sub(r"\s+#.+$", "", line)
        line = line.replace(r"\#", "#")
        if line:
            patterns.append(line)
    patterns.append(r"^/" + re.escape(LOCAL_IGNORE_FILE) + r"$")
    return patterns


def _ignore_patterns(package_dir: Path, home: Path) -> list[str]:
    for path in (package_dir / LOCAL_IGNORE_FILE, home / GLOBAL_IGNORE_FILE):
        if path.is_file():
            return _parse_ignore_file(path)
    return list(DEFAULT_IGNORE) + [r"^/" + re.escape(LOCAL_IGNORE_FILE) + r"$"]


def _is_ignored(rel: str, patterns: list[str]) -> bool:
    full = "/" + rel
    base = rel.rsplit("/", 1)[-1]
    for pattern in patterns:
        try:
            if "/" in pattern:
                if re.search(r"(^|/)(" + pattern + r")(/|$)", full):
                    return True
            elif re.fullmatch(pattern, base):
                return True
        except re.error as error:
            raise StowError(f"invalid ignore pattern {pattern!r}: {error}") from error
    return False


def _resolves_into(link: Path, source: Path) -> bool:
    """True when a symlink's target lives inside the package directory."""
    try:
        resolved = link.resolve(strict=False)
    except OSError:
        return False
    return resolved.is_relative_to(source.resolve())


def _owned(link: Path, entry: Path) -> bool:
    """True when a target symlink points at the package entry."""
    try:
        return link.resolve(strict=False) == entry.resolve(strict=False)
    except OSError:
        return False


def _iter_symlinks(root: Path):
    """Yield every symlink under root, without following directory links."""
    for base, dirs, files in os.walk(root, followlinks=False):
        for name in list(dirs) + files:
            path = Path(base) / name
            if path.is_symlink():
                yield path


def _analyze(
    source_dir: Path,
    target_dir: Path,
    rel: str,
    patterns: list[str],
    plan: Plan,
    *,
    adopt: bool,
    backup: bool,
    replaced: set[Path],
) -> None:
    for entry in sorted(source_dir.iterdir()):
        child_rel = f"{rel}/{entry.name}" if rel else entry.name
        if _is_ignored(child_rel, patterns):
            continue
        target = target_dir / entry.name
        is_dir = entry.is_dir() and not entry.is_symlink()
        if target.is_symlink():
            if target not in replaced:
                kind = "skip" if _owned(target, entry) else "conflict"
                plan.actions.append(Action(kind, target, entry))
            continue
        if is_dir and target.is_dir():
            _analyze(entry, target, child_rel, patterns, plan, adopt=adopt,
                     backup=backup, replaced=replaced)
            continue
        if target.exists():
            if adopt and not is_dir and target.is_file():
                kind = "adopt"
            elif backup:
                kind = "backup"
            else:
                kind = "conflict"
            plan.actions.append(Action(kind, target, entry))
            continue
        plan.actions.append(Action("link", target, entry))
        # A missing directory target is folded by stow into one link; the
        # entries inside it are not stowed individually.


def plan_install(
    package: Package,
    *,
    adopt: bool = False,
    backup: bool = False,
    home: Path | None = None,
) -> Plan:
    """Work out what install would do, without changing anything."""
    home = Path(home) if home is not None else Path.home()
    plan = Plan(package.name, package.source, package.target)
    patterns = _ignore_patterns(package.source, home)

    # Absolute links made by hand (stow refuses to own them). Relative links
    # that resolve into the package are left for stow to restow.
    replaced: set[Path] = set()
    if package.target.is_dir():
        for link in _iter_symlinks(package.target):
            if _resolves_into(link, package.source) and os.path.isabs(os.readlink(link)):
                replaced.add(link)

    _analyze(package.source, package.target, "", patterns, plan, adopt=adopt,
             backup=backup, replaced=replaced)
    plan.actions.extend(
        Action("replace", link, link.resolve(strict=False)) for link in sorted(replaced)
    )
    return plan


def install(
    package: Package,
    *,
    apply: bool = False,
    backup: bool = False,
    adopt: bool = False,
    home: Path | None = None,
) -> Plan:
    """Plan an install and, when apply is set, perform it."""
    plan = plan_install(package, adopt=adopt, backup=backup, home=home)
    if not apply:
        return plan
    if plan.conflicts:
        raise ConflictError(plan)

    package.target.mkdir(parents=True, exist_ok=True)
    for action in plan.by_kind("replace"):
        action.target.unlink()
    stamp = time.strftime("%Y%m%d-%H%M%S")
    for action in plan.by_kind("backup"):
        action.target.rename(action.target.with_name(f"{action.target.name}.bak.{stamp}"))
    _run_stow(package, restow=True, adopt=adopt)
    return plan


def plan_uninstall(package: Package) -> Plan:
    """List the symlinks uninstall would remove, without changing anything."""
    plan = Plan(package.name, package.source, package.target)
    if package.target.is_dir():
        for link in _iter_symlinks(package.target):
            if _resolves_into(link, package.source):
                plan.actions.append(Action("remove", link, link.resolve(strict=False)))
    return plan


def uninstall(package: Package, *, apply: bool = False) -> Plan:
    """Plan an uninstall and, when apply is set, perform it. Real files and
    target directories are never touched."""
    plan = plan_uninstall(package)
    if not apply or not plan.actions:
        return plan
    for action in plan.actions:
        action.target.unlink()
    _run_stow(package, delete=True)
    return plan


def _run_stow(package: Package, *, restow: bool = False, delete: bool = False,
              adopt: bool = False) -> subprocess.CompletedProcess:
    stow = shutil.which("stow")
    if not stow:
        raise StowMissing("GNU stow not found on PATH")
    command = [stow, "-d", str(package.source.parent), "-t", str(package.target)]
    if restow:
        command.append("-R")
    if delete:
        command.append("-D")
    if adopt:
        command.append("--adopt")
    command.append(package.source.name)
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        message = (result.stderr or result.stdout).strip()
        raise StowError(message or f"stow exited with {result.returncode}")
    return result
