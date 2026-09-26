#!/usr/bin/env python3
"""Install the Pi shell-tool timeout label patch.

Pi's `pi` binary does not load dist/core/tools/renderers/bash.js. It loads a
minified copy inside dist/bundle/chunks/. This script patches every copy it
finds, then drops Node's compile cache so the next Pi process reads the edit.

Re-run after `brew upgrade` of pi. Already-patched files are left alone.
"""

from __future__ import annotations

import shutil
import sys
import tempfile
from pathlib import Path

# Above 60s the label is minutes and seconds, and hours once that passes 60m.
# 100 -> "1m 40s". 60000 -> "16h 40m 0s".
FN_PRETTY = """function formatTimeout(timeout) {
    if (!(timeout > 60))
        return `${timeout}s`;
    const total = Math.floor(timeout);
    const minutes = Math.floor(total / 60);
    const seconds = total % 60;
    if (minutes < 60)
        return `${minutes}m ${seconds}s`;
    return `${Math.floor(minutes / 60)}h ${minutes % 60}m ${seconds}s`;
}
"""

FN_MIN = (
    "function formatTimeout(timeout){"
    "if(!(timeout>60))return `${timeout}s`;"
    "let total=Math.floor(timeout),minutes=Math.floor(total/60),seconds=total%60;"
    "return minutes<60?`${minutes}m ${seconds}s`:"
    "`${Math.floor(minutes/60)}h ${minutes%60}m ${seconds}s`}"
)

CALL_OLD = "(timeout ${timeout}s)"
CALL_NEW = "(timeout ${formatTimeout(timeout)})"
ANCHOR = "function formatShellCall"


def apply(text: str) -> str:
    """Return text with the label patch. Unchanged when already applied or absent."""
    if CALL_OLD not in text:
        return text
    if ANCHOR not in text:
        return text

    out = text.replace(CALL_OLD, CALL_NEW, 1)
    if "function formatTimeout(" in out:
        return out

    fn = FN_MIN if "function formatShellCall(" in out else FN_PRETTY
    return out.replace(ANCHOR, fn + ANCHOR, 1)


def pi_root() -> Path:
    exe = shutil.which("pi")
    if not exe:
        raise SystemExit("pi not on PATH")
    path = Path(exe).resolve()
    # Homebrew pi -> .../pi-coding-agent/dist/bundle/cli.js
    if path.parent.name == "bundle" and path.parent.parent.name == "dist":
        return path.parent.parent.parent
    raise SystemExit(f"pi is not the Homebrew package layout: {path}")


def targets(root: Path) -> list[Path]:
    dist = root / "dist"
    found = []
    # The package itself lives under Homebrew's node_modules. Only skip a
    # nested node_modules inside dist, not the install prefix.
    for path in dist.rglob("*.js"):
        if "node_modules" in path.relative_to(dist).parts:
            continue
        found.append(path)
    return found


def clear_cache() -> None:
    cache = Path(tempfile.gettempdir()) / "node-compile-cache"
    if cache.is_dir():
        shutil.rmtree(cache)


def install(root: Path) -> int:
    changed = 0
    already = 0
    for path in targets(root):
        text = path.read_text()
        if CALL_NEW in text and "function formatTimeout(" in text:
            already += 1
            continue
        out = apply(text)
        if out == text:
            continue
        path.write_text(out)
        changed += 1
        print(f"patched {path}")

    if changed == 0 and already == 0:
        print(f"no shell timeout label in {root}", file=sys.stderr)
        return 1

    clear_cache()
    print(f"patched {changed}, already {already}")
    return 0


def main() -> None:
    raise SystemExit(install(pi_root()))


if __name__ == "__main__":
    main()
