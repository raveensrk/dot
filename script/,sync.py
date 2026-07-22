#!/usr/bin/env python3
"""Sync multiple git repositories with automatic and manual modes.

Output format:  <LEVEL>: <emoji>: <repo path>: <message/reason>
  LEVEL  INFO (green) / WARNING (yellow) / ERROR (red)
  emoji  ✅ pass · ❌ fail · ⚠️ warning · 🔍 scanning

Replaces the older sync scripts. Behaviour per repo:
  - --manual                  -> open lazygit; do not fetch, merge, or push
  - not a git repo            -> skip silently
  - detached HEAD / no branch -> WARNING, open lazygit
  - fetch fails               -> ERROR, skip (reason shown)
  - dirty working tree        -> WARNING, open lazygit
  - diverged (ahead & behind) -> WARNING, open lazygit
  - ahead only                -> push
  - behind only               -> fast-forward only (failure -> lazygit)
  - up to date                -> INFO ✅
  - ignored (via --ignore or 'ignore:' list lines) -> skipped silently
"""

import argparse
import fnmatch
import os
import subprocess
import sys
from pathlib import Path

GIT_TIMEOUT_SECONDS = 60

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
counts = {"ok": 0, "pushed": 0, "synced": 0, "manual": 0, "attention": 0, "failed": 0}


def reset_counts():
    for key in counts:
        counts[key] = 0


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
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"
    try:
        result = subprocess.run(
            ["git", "-C", str(repo), *args],
            capture_output=capture,
            text=True,
            timeout=GIT_TIMEOUT_SECONDS,
            env=env,
        )
    except subprocess.TimeoutExpired:
        return 124, "", f"Git command timed out after {GIT_TIMEOUT_SECONDS} seconds"
    except OSError as exc:
        return 127, "", str(exc)
    return result.returncode, (result.stdout or "").strip(), (result.stderr or "").strip()


def open_lazygit(repo):
    try:
        return subprocess.run(["lazygit", "-p", str(repo)]).returncode
    except OSError as exc:
        error(repo, f"Could not open lazygit — {exc}")
        return 127


def open_for_attention(repo, message):
    warning(repo, f"{message} — opening lazygit")
    if open_lazygit(repo) == 0:
        counts["attention"] += 1
    else:
        counts["failed"] += 1
        error(repo, "lazygit exited unsuccessfully")


def sync_repo(repo, manual=False):
    repo = str(repo)
    rc, inside, err = git(repo, "rev-parse", "--is-inside-work-tree")
    if rc in (124, 127):
        counts["failed"] += 1
        error(repo, f"Git repository check failed — {err or 'unknown error'}")
        return
    if rc != 0 or inside != "true":
        return

    if manual:
        info(SCAN, repo, "Opening lazygit for manual handling")
        if open_lazygit(repo) == 0:
            counts["manual"] += 1
        else:
            counts["failed"] += 1
            error(repo, "lazygit exited unsuccessfully")
        return

    rc, branch, err = git(repo, "branch", "--show-current")
    if rc != 0:
        counts["failed"] += 1
        error(repo, f"Branch check failed — {err or 'unknown error'}")
        return
    if not branch:
        open_for_attention(repo, "Detached HEAD or no branch")
        return

    rc, remote, remote_err = git(repo, "config", "--get", f"branch.{branch}.remote")
    merge_rc, merge_ref, merge_err = git(repo, "config", "--get", f"branch.{branch}.merge")
    if rc not in (0, 1) or merge_rc not in (0, 1):
        counts["failed"] += 1
        reason = remote_err or merge_err or "unknown error"
        error(repo, f"Upstream configuration check failed — {reason}")
        return
    if rc != 0 or merge_rc != 0 or not remote or not merge_ref:
        open_for_attention(repo, "No upstream branch configured")
        return
    if remote == ".":
        open_for_attention(repo, "Local upstream remotes are not supported")
        return

    # Fetch the configured upstream remote.
    rc, _, err = git(repo, "fetch", remote)
    if rc != 0:
        counts["failed"] += 1
        reason = _fetch_reason(err)
        error(repo, f"Fetch failed — {reason}")
        return

    rc, upstream, err = git(
        repo, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"
    )
    if rc != 0 or not upstream:
        counts["failed"] += 1
        error(repo, f"Could not resolve upstream branch — {err or 'unknown error'}")
        return

    # Dirty working tree
    rc, status, err = git(repo, "status", "--porcelain")
    if rc != 0:
        counts["failed"] += 1
        error(repo, f"Status check failed — {err or 'unknown error'}")
        return
    if status:
        n = len(status.splitlines())
        open_for_attention(repo, f"Uncommitted changes ({n} file(s))")
        return

    # Ahead / behind
    rc, comparison, err = git(repo, "rev-list", "--left-right", "--count", f"HEAD...{upstream}")
    parts = comparison.split()
    if rc != 0 or len(parts) != 2 or not all(part.isdigit() for part in parts):
        counts["failed"] += 1
        error(repo, f"Upstream comparison failed — {err or comparison or 'invalid Git output'}")
        return
    ahead, behind = map(int, parts)

    # Diverged
    if ahead > 0 and behind > 0:
        open_for_attention(repo, f"Diverged (ahead {ahead}, behind {behind})")
        return

    # Ahead only -> push
    if ahead > 0:
        rc, _, err = git(repo, "push", remote, f"HEAD:{merge_ref}")
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

    # Behind only -> fast-forward to the already-fetched upstream. No push is needed.
    rc, _, err = git(repo, "merge", "--ff-only", upstream)
    if rc == 0:
        counts["synced"] += 1
        info(PASS, repo, f"Fast-forwarded by {behind} remote commit(s)")
    else:
        open_for_attention(repo, f"Fast-forward failed — {err or 'upstream changed'}")


def _fetch_reason(stderr):
    """Turn raw git fetch stderr into a short human reason."""
    low = stderr.lower()
    if "does not appear to be a git repository" in low or "could not read from remote" in low:
        return "configured upstream remote is missing or unreachable"
    if "could not resolve host" in low or "network is unreachable" in low:
        return "network unreachable"
    if "permission denied" in low or "access rights" in low:
        return "authentication/permission denied"
    # Fall back to the first non-empty line of git's own message.
    for ln in stderr.splitlines():
        if ln.strip():
            return ln.strip()
    return "unknown error"


def is_ignored(path, ignore_patterns):
    """True if path matches an ignore pattern (glob) or lies under an ignored path."""
    for pat in ignore_patterns:
        if fnmatch.fnmatch(path, pat):
            return True
        if not any(ch in pat for ch in "*?[") and (
            path == pat or path.startswith(pat.rstrip("/") + "/")
        ):
            return True
    return False


def collect_repos(list_files, target_dirs, ignore_patterns):
    repos = []
    for lf in list_files:
        lf = _expand_path(lf)
        if not lf.is_file():
            counts["failed"] += 1
            error(str(lf), "List file not found")
            continue
        try:
            lines = lf.read_text().splitlines()
        except (OSError, UnicodeError) as exc:
            counts["failed"] += 1
            error(str(lf), f"Could not read list file — {exc}")
            continue
        for raw in lines:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("dir:"):
                target_dirs.append(_expand_path(line[4:].strip(), base=lf.parent))
                continue
            if line.startswith("ignore:"):
                ignore_patterns.append(_expand_ignore(line[7:].strip(), base=lf.parent))
                continue
            repos.append(str(_expand_path(line, base=lf.parent)))

    for td in target_dirs:
        td = _expand_path(td)
        if not td.is_dir():
            counts["failed"] += 1
            error(str(td), "Directory not found")
            continue
        info(SCAN, str(td), "Scanning for repositories")
        try:
            for git_dir in td.rglob(".git"):
                if git_dir.exists():
                    repos.append(str(git_dir.parent))
        except OSError as exc:
            counts["failed"] += 1
            error(str(td), f"Repository scan failed — {exc}")
    return repos


def _expand_ignore(value, base=None):
    """Expand an ignore entry; glob patterns are kept relative-friendly, plain paths expanded."""
    value = os.path.expandvars(os.path.expanduser(str(value)))
    if any(ch in value for ch in "*?["):
        return value
    return str(_expand_path(value, base=base))


def _expand_path(value, base=None):
    path = Path(os.path.expandvars(str(value))).expanduser()
    if base is not None and not path.is_absolute():
        path = Path(base) / path
    return path


def dedup(repos):
    resolved = []
    for repo in repos:
        try:
            resolved.append(str(_expand_path(repo).resolve()))
        except OSError:
            resolved.append(str(_expand_path(repo)))
    return sorted(set(resolved))


def print_summary():
    total = sum(counts.values())
    parts = [
        f"{counts['ok']} up-to-date",
        f"{counts['pushed']} pushed",
        f"{counts['synced']} synced",
        f"{counts['manual']} handled manually",
        f"{counts['attention']} need attention",
        f"{counts['failed']} failed",
    ]
    emoji = FAIL if counts["failed"] else (WARN if counts["attention"] else PASS)
    color = RED if counts["failed"] else (YELLOW if counts["attention"] else GREEN)
    _line("INFO", color, emoji, f"{total} item(s) processed", ", ".join(parts))


def main():
    reset_counts()
    parser = argparse.ArgumentParser(
        description="Sync multiple git repositories automatically or manually.",
    )
    parser.add_argument("-d", "--dir", action="append", default=[], metavar="DIR",
                        help="directory to scan for repos (repeatable)")
    parser.add_argument("-f", "--file", action="append", default=[], metavar="FILE",
                        help="file listing repo paths, one per line; "
                             "prefix a line with 'dir:' to scan a directory recursively, "
                             "or 'ignore:' to skip a path or glob pattern (repeatable)")
    parser.add_argument("-i", "--ignore", action="append", default=[], metavar="PATTERN",
                        help="path or glob pattern to skip; repos under a plain path are "
                             "also skipped (repeatable; also 'ignore:' lines in list files)")
    parser.add_argument("-m", "--manual", action="store_true",
                        help="open every repository in lazygit; do not fetch, merge, or push")
    args = parser.parse_args()

    list_files = list(args.file)
    target_dirs = list(args.dir)
    if not list_files and not target_dirs:
        list_files.append(str(REPO_LIST))
        target_dirs.append(str(DEFAULT_REPO_DIR))

    ignore_patterns = [_expand_ignore(p) for p in args.ignore]
    repos = dedup(collect_repos(list_files, target_dirs, ignore_patterns))
    repos = [r for r in repos if not is_ignored(r, ignore_patterns)]
    for repo in repos:
        try:
            sync_repo(repo, manual=args.manual)
        except Exception as exc:  # keep going on unexpected failure
            counts["failed"] += 1
            error(repo, f"Unexpected error — {exc}")

    print()
    print_summary()
    if counts["failed"]:
        return 1
    if counts["attention"]:
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
