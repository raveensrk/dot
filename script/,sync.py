#!/usr/bin/env python3
"""Sync multiple git repositories with automatic and manual modes.

Output format:  <LEVEL>: <emoji>: <repo path>: <message/reason>
  LEVEL  INFO (green) / WARNING (yellow) / ERROR (red)
  emoji  ✅ pass · ❌ fail · ⚠️ warning · 🔍 scanning

Repos are synced in parallel (-j/--jobs, default 8). Nothing interactive
happens during the scan: repos needing a human are only recorded. Afterwards
the synced repos are reported first, then the ones needing attention, and each
of those is prompted: y = open lazygit, n = leave it, i = ignore it now and on
future runs (appended to ~/dot_local/list_of_ignores.txt), q = stop prompting.

Behaviour per repo:
  - --manual                  -> open lazygit; do not fetch, merge, or push
  - not a git repo            -> skip silently
  - detached HEAD / no branch -> needs attention
  - fetch fails               -> ERROR, skip (reason shown)
  - dirty working tree        -> needs attention
  - diverged (ahead & behind) -> needs attention
  - ahead only                -> push
  - behind only               -> fast-forward only (failure -> needs attention)
  - up to date                -> INFO ✅
  - ignored (via --ignore or 'ignore:' list lines) -> skipped silently
"""

import argparse
import concurrent.futures
import fnmatch
import os
import subprocess
import sys
from collections import namedtuple
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
# Personal, untracked skip list. Always applied, regardless of --file/--dir.
LOCAL_IGNORE_LIST = Path.home() / "dot_local" / "list_of_ignores.txt"

# --- tally ----------------------------------------------------------------
counts = {"ok": 0, "pushed": 0, "synced": 0, "manual": 0, "attention": 0, "failed": 0}

# One repo's outcome. `status` is a key of `counts`, or "skip" for paths that
# turned out not to be git repositories.
Result = namedtuple("Result", "repo status message")
SYNCED_STATUSES = ("ok", "pushed", "synced")


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


def sync_repo(repo):
    """Inspect and sync one repo. Pure worker: no printing, no lazygit.

    Returns a Result whose status is one of the `counts` keys, or "skip" for
    paths that are not git repositories.
    """
    repo = str(repo)
    rc, inside, err = git(repo, "rev-parse", "--is-inside-work-tree")
    if rc in (124, 127):
        return Result(repo, "failed", f"Git repository check failed — {err or 'unknown error'}")
    if rc != 0 or inside != "true":
        return Result(repo, "skip", "Not a git repository")

    rc, branch, err = git(repo, "branch", "--show-current")
    if rc != 0:
        return Result(repo, "failed", f"Branch check failed — {err or 'unknown error'}")
    if not branch:
        return Result(repo, "attention", "Detached HEAD or no branch")

    rc, remote, remote_err = git(repo, "config", "--get", f"branch.{branch}.remote")
    merge_rc, merge_ref, merge_err = git(repo, "config", "--get", f"branch.{branch}.merge")
    if rc not in (0, 1) or merge_rc not in (0, 1):
        reason = remote_err or merge_err or "unknown error"
        return Result(repo, "failed", f"Upstream configuration check failed — {reason}")
    if rc != 0 or merge_rc != 0 or not remote or not merge_ref:
        return Result(repo, "attention", "No upstream branch configured")
    if remote == ".":
        return Result(repo, "attention", "Local upstream remotes are not supported")

    # Fetch the configured upstream remote.
    rc, _, err = git(repo, "fetch", remote)
    if rc != 0:
        return Result(repo, "failed", f"Fetch failed — {_fetch_reason(err)}")

    rc, upstream, err = git(
        repo, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"
    )
    if rc != 0 or not upstream:
        return Result(repo, "failed", f"Could not resolve upstream branch — {err or 'unknown error'}")

    # Dirty working tree
    rc, status, err = git(repo, "status", "--porcelain")
    if rc != 0:
        return Result(repo, "failed", f"Status check failed — {err or 'unknown error'}")
    if status:
        n = len(status.splitlines())
        return Result(repo, "attention", f"Uncommitted changes ({n} file(s))")

    # Ahead / behind
    rc, comparison, err = git(repo, "rev-list", "--left-right", "--count", f"HEAD...{upstream}")
    parts = comparison.split()
    if rc != 0 or len(parts) != 2 or not all(part.isdigit() for part in parts):
        reason = err or comparison or "invalid Git output"
        return Result(repo, "failed", f"Upstream comparison failed — {reason}")
    ahead, behind = map(int, parts)

    # Diverged
    if ahead > 0 and behind > 0:
        return Result(repo, "attention", f"Diverged (ahead {ahead}, behind {behind})")

    # Ahead only -> push
    if ahead > 0:
        rc, _, err = git(repo, "push", remote, f"HEAD:{merge_ref}")
        if rc == 0:
            return Result(repo, "pushed", f"Pushed {ahead} local commit(s)")
        return Result(repo, "failed", f"Push failed — {err or 'see git output'}")

    # Up to date
    if behind == 0:
        return Result(repo, "ok", "Already up to date")

    # Behind only -> fast-forward to the already-fetched upstream. No push is needed.
    rc, _, err = git(repo, "merge", "--ff-only", upstream)
    if rc == 0:
        return Result(repo, "synced", f"Fast-forwarded by {behind} remote commit(s)")
    return Result(repo, "attention", f"Fast-forward failed — {err or 'upstream changed'}")


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


def read_ignore_file(path):
    """Read ignore patterns from a file, one per line.

    Blank lines and '#' comments are skipped. Returns [] if the file is
    absent (a missing local ignore list is normal, not an error).
    """
    path = _expand_path(path)
    if not path.is_file():
        return []
    try:
        lines = path.read_text().splitlines()
    except (OSError, UnicodeError) as exc:
        error(str(path), f"Could not read ignore file — {exc}")
        return []
    patterns = []
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        patterns.append(_expand_ignore(line, base=path.parent))
    return patterns


def add_to_ignore_list(repo):
    """Append repo to the local ignore list so future runs skip it.

    Returns True if the repo is ignored from now on (already listed counts as
    success), False if the file could not be written.
    """
    path = _expand_path(LOCAL_IGNORE_LIST)
    if is_ignored(str(repo), read_ignore_file(path)):
        return True
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        # Don't glue the new entry onto an unterminated last line.
        prefix = ""
        if path.is_file():
            existing = path.read_text()
            if existing and not existing.endswith("\n"):
                prefix = "\n"
        with path.open("a") as handle:
            handle.write(f"{prefix}{repo}\n")
    except (OSError, UnicodeError) as exc:
        error(str(path), f"Could not update ignore list — {exc}")
        return False
    return True


def collect_repos(list_files, target_dirs, ignore_patterns=None):
    if ignore_patterns is None:
        ignore_patterns = []
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


def run_parallel(repos, jobs):
    """Sync every repo concurrently, printing progress as futures land."""
    results = []
    total = len(repos)
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        futures = {pool.submit(sync_repo, repo): repo for repo in repos}
        for done, future in enumerate(concurrent.futures.as_completed(futures), start=1):
            repo = futures[future]
            try:
                results.append(future.result())
            except Exception as exc:  # keep going on unexpected failure
                results.append(Result(repo, "failed", f"Unexpected error — {exc}"))
            _line("INFO", GREEN, SCAN, f"{done}/{total}", repo)
    return sorted(results, key=lambda r: r.repo)


def report(results):
    """Print synced repos first, then the ones needing a human."""
    synced = [r for r in results if r.status in SYNCED_STATUSES]
    attention = [r for r in results if r.status == "attention"]
    failed = [r for r in results if r.status == "failed"]

    if synced:
        print()
        print("Synced:")
        for r in synced:
            info(PASS, r.repo, r.message)
    if attention or failed:
        print()
        print("Needs attention:")
        for r in attention:
            warning(r.repo, r.message)
        for r in failed:
            error(r.repo, r.message)


def prompt_for_attention(results):
    """Ask, per repo needing attention, whether to open lazygit.

    Returns the number of repos whose lazygit exited unsuccessfully; those are
    counted as failures.
    """
    failures = 0
    attention = [r for r in results if r.status == "attention"]
    if not attention:
        return 0
    print()
    for r in attention:
        try:
            answer = input(f"Open lazygit for {r.repo}? [y/N/i/q] ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if answer in ("q", "quit"):
            break
        if answer in ("i", "ignore"):
            if add_to_ignore_list(r.repo):
                info(PASS, r.repo, f"Ignored — added to {LOCAL_IGNORE_LIST}")
            continue
        if answer not in ("y", "yes"):
            continue
        if open_lazygit(r.repo) != 0:
            error(r.repo, "lazygit exited unsuccessfully")
            failures += 1
    return failures


def run_manual(repos):
    """Open every repo in lazygit, one at a time. Inherently serial."""
    for repo in repos:
        rc, inside, err = git(repo, "rev-parse", "--is-inside-work-tree")
        if rc in (124, 127):
            counts["failed"] += 1
            error(repo, f"Git repository check failed — {err or 'unknown error'}")
            continue
        if rc != 0 or inside != "true":
            continue
        info(SCAN, repo, "Opening lazygit for manual handling")
        if open_lazygit(repo) == 0:
            counts["manual"] += 1
        else:
            counts["failed"] += 1
            error(repo, "lazygit exited unsuccessfully")


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
                             "also skipped (repeatable; also 'ignore:' lines in list files "
                             "and one-per-line entries in ~/dot_local/list_of_ignores.txt, "
                             "which answering 'i' at the attention prompt appends to)")
    parser.add_argument("-m", "--manual", action="store_true",
                        help="open every repository in lazygit; do not fetch, merge, or push")
    parser.add_argument("-j", "--jobs", type=int, default=8, metavar="N",
                        help="number of repositories to sync concurrently (default: 8)")
    parser.add_argument("-y", "--no-prompt", action="store_true",
                        help="report only; never prompt to open or ignore a repository")
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be at least 1")

    list_files = list(args.file)
    target_dirs = list(args.dir)
    if not list_files and not target_dirs:
        list_files.append(str(REPO_LIST))
        target_dirs.append(str(DEFAULT_REPO_DIR))

    ignore_patterns = [_expand_ignore(p) for p in args.ignore]
    ignore_patterns.extend(read_ignore_file(LOCAL_IGNORE_LIST))
    repos = dedup(collect_repos(list_files, target_dirs, ignore_patterns))
    repos = [r for r in repos if not is_ignored(r, ignore_patterns)]
    if args.manual:
        run_manual(repos)
    else:
        results = run_parallel(repos, args.jobs)
        for r in results:
            if r.status in counts:
                counts[r.status] += 1
        report(results)
        if not args.no_prompt and sys.stdin.isatty():
            failures = prompt_for_attention(results)
            counts["attention"] -= failures
            counts["failed"] += failures

    print()
    print_summary()
    if counts["failed"]:
        return 1
    if counts["attention"]:
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
