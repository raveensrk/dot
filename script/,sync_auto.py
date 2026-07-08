#!/usr/bin/env python3
"""Auto-sync multiple git repositories with clear, colored, one-line status output.

Output format:  <LEVEL>: <emoji>: <repo path>: <message/reason>
  LEVEL  INFO (green) / WARNING (yellow) / ERROR (red)
  emoji  ✅ pass · ❌ fail · ⚠️ warning · 🔍 scanning

Replaces the older ,sync_auto.sh. Behaviour per repo:
  - not a git repo            -> skip silently
  - detached HEAD / no branch -> WARNING, open lazygit
  - fetch fails               -> ERROR, skip (reason shown)
  - dirty working tree        -> WARNING, open lazygit
  - diverged (ahead & behind) -> WARNING, open lazygit
  - ahead only                -> push
  - behind only               -> merge --no-ff then push (conflict -> lazygit)
  - up to date                -> INFO ✅
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

# --- colors ---------------------------------------------------------------
_USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None
GREEN = "\033[0;32m" if _USE_COLOR else ""
RED = "\033[0;31m" if _USE_COLOR else ""
YELLOW = "\033[0;33m" if _USE_COLOR else ""
NOCOLOR = "\033[0m" if _USE_COLOR else ""

PASS = "✅"
FAIL = "❌"
WARN = "⚠️"
SCAN = "🔍"

REPO_LIST = Path.home() / "dot_local" / "list_of_repos.txt"
DEFAULT_REPO_DIR = Path.home() / "repos"

# --- tally ----------------------------------------------------------------
counts = {"ok": 0, "pushed": 0, "synced": 0, "attention": 0, "failed": 0}


def _line(level, color, emoji, repo, message):
    print(f"{color}{level}{NOCOLOR}: {emoji}: {repo}: {message}")


def info(emoji, repo, message):
    _line("INFO", GREEN, emoji, repo, message)


def warning(repo, message):
    _line("WARNING", YELLOW, WARN, repo, message)


def error(repo, message):
    _line("ERROR", RED, FAIL, repo, message)


def git(repo, *args, capture=True):
    """Run a git command in repo. Returns (returncode, stdout, stderr)."""
    result = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=capture,
        text=True,
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def open_lazygit(repo):
    subprocess.run(["lazygit", "-p", str(repo)])


def sync_repo(repo):
    repo = str(repo)
    if not os.path.isdir(os.path.join(repo, ".git")):
        return

    rc, branch, _ = git(repo, "branch", "--show-current")
    if rc != 0 or not branch:
        counts["attention"] += 1
        warning(repo, "Detached HEAD or no branch — opening lazygit")
        open_lazygit(repo)
        return

    # Fetch
    rc, _, err = git(repo, "fetch", "origin")
    if rc != 0:
        counts["failed"] += 1
        reason = _fetch_reason(err)
        error(repo, f"Fetch failed — {reason}")
        return

    # Dirty working tree
    _, status, _ = git(repo, "status", "--porcelain")
    if status:
        counts["attention"] += 1
        n = len(status.splitlines())
        warning(repo, f"Uncommitted changes ({n} file(s)) — opening lazygit")
        open_lazygit(repo)
        return

    # Ahead / behind
    _, ahead_s, _ = git(repo, "rev-list", f"origin/{branch}..HEAD", "--count")
    _, behind_s, _ = git(repo, "rev-list", f"HEAD..origin/{branch}", "--count")
    ahead = int(ahead_s) if ahead_s.isdigit() else 0
    behind = int(behind_s) if behind_s.isdigit() else 0

    # Diverged
    if ahead > 0 and behind > 0:
        counts["attention"] += 1
        warning(repo, f"Diverged (ahead {ahead}, behind {behind}) — opening lazygit")
        open_lazygit(repo)
        return

    # Ahead only -> push
    if ahead > 0:
        rc, _, err = git(repo, "push", "origin", branch)
        if rc == 0:
            counts["pushed"] += 1
            info(PASS, repo, f"Pushed {ahead} local commit(s)")
        else:
            counts["failed"] += 1
            error(repo, f"Push failed — {err or 'see git output'}")
        return

    # Up to date
    if behind == 0:
        counts["ok"] += 1
        info(PASS, repo, "Already up to date")
        return

    # Behind only -> merge then push
    rc, _, err = git(repo, "merge", "--no-ff", f"origin/{branch}", "--no-edit")
    if rc == 0:
        rc, _, perr = git(repo, "push", "origin", branch)
        if rc == 0:
            counts["synced"] += 1
            info(PASS, repo, f"Merged {behind} remote commit(s) and pushed")
        else:
            counts["failed"] += 1
            error(repo, f"Merged but push failed — {perr or 'see git output'}")
    else:
        counts["attention"] += 1
        git(repo, "merge", "--abort")
        warning(repo, f"Merge conflict on {behind} remote commit(s) — opening lazygit")
        open_lazygit(repo)


def _fetch_reason(stderr):
    """Turn raw git fetch stderr into a short human reason."""
    low = stderr.lower()
    if "does not appear to be a git repository" in low or "could not read from remote" in low:
        return "no 'origin' remote configured or remote unreachable"
    if "could not resolve host" in low or "network is unreachable" in low:
        return "network unreachable"
    if "permission denied" in low or "access rights" in low:
        return "authentication/permission denied"
    # Fall back to the first non-empty line of git's own message.
    for ln in stderr.splitlines():
        if ln.strip():
            return ln.strip()
    return "unknown error"


def collect_repos(list_files, target_dirs):
    repos = []
    for lf in list_files:
        lf = Path(lf)
        if not lf.is_file():
            error(str(lf), "List file not found")
            continue
        for raw in lf.read_text().splitlines():
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            repos.append(line)

    for td in target_dirs:
        td = Path(td)
        if not td.is_dir():
            error(str(td), "Directory not found")
            continue
        info(SCAN, str(td), "Scanning for repositories")
        for git_dir in td.rglob(".git"):
            if git_dir.is_dir():
                repos.append(str(git_dir.parent))
    return repos


def dedup(repos):
    seen = set()
    ordered = []
    for repo in repos:
        try:
            resolved = str(Path(repo).resolve())
        except OSError:
            resolved = repo
        if resolved in seen:
            continue
        seen.add(resolved)
        ordered.append(repo)
    return ordered


def print_summary():
    total = sum(counts.values())
    parts = [
        f"{counts['ok']} up-to-date",
        f"{counts['pushed']} pushed",
        f"{counts['synced']} synced",
        f"{counts['attention']} need attention",
        f"{counts['failed']} failed",
    ]
    emoji = FAIL if counts["failed"] else (WARN if counts["attention"] else PASS)
    color = RED if counts["failed"] else (YELLOW if counts["attention"] else GREEN)
    _line("INFO", color, emoji, f"{total} repos processed", ", ".join(parts))


def main():
    parser = argparse.ArgumentParser(
        description="Auto-sync multiple git repositories with clear colored output.",
    )
    parser.add_argument("-d", "--dir", action="append", default=[], metavar="DIR",
                        help="directory to scan for repos (repeatable)")
    parser.add_argument("-f", "--file", action="append", default=[], metavar="FILE",
                        help="file listing repo paths, one per line (repeatable)")
    args = parser.parse_args()

    list_files = list(args.file)
    target_dirs = list(args.dir)
    if not list_files and not target_dirs:
        list_files.append(str(REPO_LIST))
        target_dirs.append(str(DEFAULT_REPO_DIR))

    repos = dedup(collect_repos(list_files, target_dirs))
    for repo in repos:
        try:
            sync_repo(repo)
        except Exception as exc:  # keep going on unexpected failure
            counts["failed"] += 1
            error(repo, f"Unexpected error — {exc}")

    print()
    print_summary()


if __name__ == "__main__":
    main()
