#!/usr/bin/env python3

"""Scan Markdown tasks and source comments with ripgrep."""

from __future__ import annotations

import argparse
import base64
import datetime
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import tomllib
from dataclasses import dataclass, field
from pathlib import Path


class TodoError(Exception):
    """A user-facing scanner error."""


@dataclass
class TodoConfig:
    """Scanner configuration loaded from TOML."""

    patterns: list[str] = field(
        default_factory=lambda: ["TODO", "IN_PROGRESS", "FIXME", "BUG", "LATER"]
    )
    checkbox_patterns: list[str] = field(default_factory=lambda: [r"\[ \]"])
    exclude_patterns: list[str] = field(default_factory=lambda: ["LATER"])
    states: list[str] = field(
        default_factory=lambda: [
            "TODO",
            "IN_PROGRESS",
            "OPTIONAL",
            "LATER",
            "DONE",
            "OBSOLETE",
        ]
    )
    extensions: list[str] = field(default_factory=lambda: ["md"])
    source_extensions: list[str] = field(default_factory=list)
    default_dirs: list[str] = field(default_factory=lambda: ["."])
    ignore: list[str] = field(default_factory=list)
    others: list[str] = field(default_factory=list)
    flow_order: list[str] = field(
        default_factory=lambda: [
            "IN_PROGRESS",
            "TODO",
            "[ ]",
            "FIXME",
            "BUG",
            "LATER",
        ]
    )
    comment_prefix_pattern: str = r'//+|#|--|;|/\*+|\*+|<!--|%'

    KNOWN_FIELDS = {
        "patterns",
        "checkbox_patterns",
        "exclude_patterns",
        "states",
        "extensions",
        "source_extensions",
        "default_dirs",
        "ignore",
        "others",
        "flow_order",
        "comment_prefix_pattern",
    }

    @staticmethod
    def _read(path: Path | None) -> dict:
        """Read a TOML file into a dict, or {} when absent."""
        if path is None or not path.is_file():
            return {}
        try:
            with path.open("rb") as stream:
                return tomllib.load(stream)
        except (OSError, tomllib.TOMLDecodeError) as error:
            raise TodoError(f"cannot read configuration {path}: {error}") from error

    @staticmethod
    def _merge(base: dict, overlay: dict) -> dict:
        """Overlay `overlay` onto `base`; `ignore` is appended, others replaced."""
        merged = dict(base)
        for key, value in overlay.items():
            if (
                key == "ignore"
                and isinstance(value, list)
                and isinstance(merged.get(key), list)
            ):
                combined = list(merged[key])
                for item in value:
                    if item not in combined:
                        combined.append(item)
                merged[key] = combined
            else:
                merged[key] = value
        return merged

    @classmethod
    def load(cls, path: Path | None, local_path: Path | None = None) -> TodoConfig:
        config = cls()
        values = cls._read(path)
        if local_path is not None:
            values = cls._merge(values, cls._read(local_path))

        unknown = sorted(set(values) - cls.KNOWN_FIELDS)
        if unknown:
            raise TodoError(f"unknown configuration keys: {', '.join(unknown)}")

        for name in cls.KNOWN_FIELDS - {"comment_prefix_pattern"}:
            if name not in values:
                continue
            value = values[name]
            if not isinstance(value, list) or not all(
                isinstance(item, str) for item in value
            ):
                raise TodoError(f"configuration '{name}' must be an array of strings")
            setattr(config, name, value)

        if "comment_prefix_pattern" in values:
            prefix = values["comment_prefix_pattern"]
            if not isinstance(prefix, str):
                raise TodoError("configuration 'comment_prefix_pattern' must be a string")
            config.comment_prefix_pattern = prefix

        if not config.patterns:
            raise TodoError("configuration 'patterns' must not be empty")
        if not config.extensions:
            raise TodoError("configuration 'extensions' must not be empty")
        if not config.states:
            raise TodoError("configuration 'states' must not be empty")
        return config


@dataclass(frozen=True, order=True)
class TodoMatch:
    """One ripgrep match."""

    file: str
    line: int
    column: int
    text: str

    def vimgrep(self) -> str:
        return f"{self.file}:{self.line}:{self.column}:{self.text}"

    def as_dict(self) -> dict[str, str | int]:
        return {
            "file": self.file,
            "line": self.line,
            "column": self.column,
            "text": self.text,
        }


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog=",todo.py",
        description="Scan Markdown tasks and source-code comments for outstanding work.",
    )
    parser.add_argument(
        "-f",
        "--format",
        choices=("vim", "plain", "fzf", "json", "markdown"),
        default="vim",
        help="output format (default: vim)",
    )
    parser.add_argument(
        "--all-extensions",
        action="store_true",
        help="also scan source_extensions for comment-style tasks",
    )
    parser.add_argument(
        "-e",
        "--include-excluded",
        action="store_true",
        help="also report statuses hidden by exclude_patterns (e.g. LATER)",
    )
    parser.add_argument(
        "-d",
        "--due",
        action="store_true",
        help="only tasks whose due: date is today or earlier",
    )
    parser.add_argument(
        "--states",
        action="store_true",
        help="print the configured lifecycle states, one per line, and exit",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        metavar="PATH",
        help="paths to scan instead of configured default_dirs",
    )
    return parser.parse_args(argv)


def config_path() -> Path:
    configured = os.environ.get("TODO_CONFIG")
    if configured:
        return Path(configured).expanduser()
    repository_config = Path(__file__).resolve().parent.parent / "config" / "todo.toml"
    if repository_config.is_file():
        return repository_config
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    return config_home / "todo" / "config.toml"


def local_config_path() -> Path | None:
    """Machine-local overlay config, merged over the committed one.

    Holds computer-specific settings (e.g. private `ignore` paths) that must not
    be committed. Skipped entirely when TODO_CONFIG pins an explicit config, so
    that path stays authoritative (and tests stay hermetic).
    """
    configured = os.environ.get("TODO_CONFIG_LOCAL")
    if configured:
        return Path(configured).expanduser()
    if os.environ.get("TODO_CONFIG"):
        return None
    local = Path.home() / "dot_local" / "config" / "todo.toml"
    return local if local.is_file() else None


def expand_path(value: str) -> Path:
    return Path(os.path.expandvars(value)).expanduser()


def existing_paths(values: list[str]) -> list[Path]:
    paths: list[Path] = []
    for value in values:
        path = expand_path(value)
        if path.exists():
            # Absolute, so ripgrep prints absolute paths and drop_ignored_paths()
            # can compare them against absolute `ignore` entries.
            paths.append(path.absolute())
        else:
            print(f"todo: skipping missing path: {path}", file=sys.stderr)
    if not paths:
        raise TodoError("none of the search paths exist")
    return paths


def alternation(patterns: list[str]) -> str:
    return "|".join(f"(?:{pattern})" for pattern in patterns)


def build_patterns(config: TodoConfig) -> tuple[str, str]:
    keywords = alternation(config.patterns)
    markdown_items = rf"(?:{keywords}):[[:blank:]]+.*[^[:space:]].*"
    if config.checkbox_patterns:
        checkboxes = alternation(config.checkbox_patterns)
        markdown_items += rf"|(?:{checkboxes})[[:blank:]]+.*[^[:space:]].*"

    markdown = rf"^[[:blank:]]*-[[:blank:]]+(?:{markdown_items})"
    source = (
        rf'(?:(?:^|[[:blank:]])(?:{config.comment_prefix_pattern})|'
        rf'^[[:blank:]]*")[[:blank:]]*(?:{keywords}):'
        rf"[[:blank:]]+.*[^[:space:]].*"
    )
    return markdown, source


def is_absolute_ignore(pattern: str) -> bool:
    """True if an `ignore` entry names one exact path rather than a name."""
    pattern = os.path.expandvars(pattern)
    return pattern.startswith("/") or pattern.startswith("~")


def ignore_patterns(pattern: str) -> list[str]:
    """Translate one relative `ignore` entry into ripgrep glob patterns.

    A bare "!dir" glob prunes a directory found *during* the walk, but never
    the search root itself -- scanning an ignored directory directly still
    reports every file under it. Excluding the contents too ("!dir/**") covers
    that case.

    Absolute entries get no glob at all. Ripgrep matches globs against the path
    as it renders it, and "**/" spans whole path components, so it cannot
    absorb the leading "/" that starts an absolute path: "**//abs/path" never
    matches, and a bare "/abs/path" anchors to the cwd instead of to the
    filesystem root. There is no glob spelling for "this exact absolute path",
    so drop_ignored_paths() enforces those entries after the search instead.
    """
    pattern = os.path.expandvars(pattern).rstrip("/")
    if not pattern or is_absolute_ignore(pattern):
        return []
    if not pattern.startswith("**"):
        pattern = f"**/{pattern}"
    return [pattern, f"{pattern}/**"]


def drop_ignored_paths(
    matches: list[TodoMatch], config: TodoConfig
) -> list[TodoMatch]:
    """Drop matches under an absolute `ignore` entry.

    Relative entries are handled by globs during the search; absolute ones
    cannot be (see ignore_patterns()), so they are applied here, where an exact
    path comparison is available.
    """
    roots = [
        expand_path(pattern.rstrip("/")).absolute()
        for pattern in config.ignore
        if is_absolute_ignore(pattern)
    ]
    if not roots:
        return matches

    def ignored(match: TodoMatch) -> bool:
        path = Path(match.file).absolute()
        return any(path == root or root in path.parents for root in roots)

    return [match for match in matches if not ignored(match)]


def ignore_globs(config: TodoConfig) -> list[str]:
    globs: list[str] = []
    for pattern in config.ignore:
        for glob in ignore_patterns(pattern):
            globs.extend(("--glob", f"!{glob}"))
    return globs


def rg_json(pattern: str, globs: list[str], paths: list[Path]) -> list[TodoMatch]:
    command = [
        "rg",
        "--json",
        "--case-sensitive",
        *globs,
        "--",
        pattern,
        *(str(path) for path in paths),
    ]
    process = subprocess.run(command, capture_output=True, check=False, text=True)
    if process.returncode not in (0, 1):
        message = process.stderr.strip() or f"ripgrep exited with {process.returncode}"
        raise TodoError(message)

    matches: list[TodoMatch] = []
    for output_line in process.stdout.splitlines():
        event = json.loads(output_line)
        if event.get("type") != "match":
            continue
        data = event["data"]
        path = rg_data_text(data["path"])
        line_text = rg_data_text(data["lines"])
        submatches = data.get("submatches", [])
        if not submatches:
            continue
        matches.append(
            TodoMatch(
                file=path,
                line=data["line_number"],
                column=submatches[0]["start"] + 1,
                text=line_text.rstrip("\r\n"),
            )
        )
    return matches


def rg_data_text(value: dict[str, str]) -> str:
    """Decode ripgrep JSON data represented as either text or base64 bytes."""
    if "text" in value:
        return value["text"]
    encoded = value.get("bytes", "")
    return base64.b64decode(encoded).decode("utf-8", errors="replace")


def fenced_line_numbers(path: str) -> set[int]:
    """Return the 1-based line numbers inside fenced code blocks of a file.

    Fences are delimited by runs of at least three backticks or tildes. The
    fence delimiters themselves are treated as inside the block.
    """
    try:
        text = Path(path).read_text(encoding="utf-8", errors="replace")
    except OSError:
        return set()

    inside: set[int] = set()
    fence: str | None = None
    for number, raw in enumerate(text.splitlines(), start=1):
        stripped = raw.lstrip()
        marker = None
        for char in ("`", "~"):
            if stripped.startswith(char * 3):
                run = len(stripped) - len(stripped.lstrip(char))
                marker = char * run
                break
        if fence is None:
            if marker is not None:
                fence = marker
                inside.add(number)
        else:
            inside.add(number)
            # A closing fence uses the same character and is at least as long,
            # with nothing but the fence characters on the line.
            if (
                marker is not None
                and marker[0] == fence[0]
                and len(marker) >= len(fence)
                and stripped.rstrip() == marker
            ):
                fence = None
    return inside


def drop_fenced(matches: list[TodoMatch]) -> list[TodoMatch]:
    """Remove Markdown matches that fall inside fenced code blocks."""
    fenced: dict[str, set[int]] = {}
    kept: list[TodoMatch] = []
    for match in matches:
        lines = fenced.get(match.file)
        if lines is None:
            lines = fenced_line_numbers(match.file)
            fenced[match.file] = lines
        if match.line not in lines:
            kept.append(match)
    return kept


_MENTION_RE = re.compile(r"@([A-Za-z0-9_-]+)")


# --- Org schema scanning (~/repos/ai/docs/agents/todo_schema.org) ---

ORG_HEADING = re.compile(r"^(\*+) (\S+)(.*)$")
ORG_BLOCK = re.compile(r"^\s*#\+(BEGIN|END)_(\S+)\s*$")
ORG_TODO_LINE = re.compile(r"^#\+TODO:\s*(.+)$")
ORG_STAMP = re.compile(
    r"[<\[](\d{4})-(\d{2})-(\d{2}) ?([A-Za-z]{3})?[^>\]]*[>\]]"
)
ORG_DEADLINE = re.compile(r"^\s*DEADLINE:\s*<")
ORG_GLOBS = ("*.org", "*.org_archive")
ORG_SKIP_DIRS = {".git", "node_modules", "target", "dist", "build", ".venv", "venv"}


def near_miss(a: str, b: str) -> bool:
    """True if `a` is one edit away from `b`: substitution, transposition,
    insertion or deletion. The schema's near-miss rule."""
    if abs(len(a) - len(b)) > 1:
        return False
    if len(a) == len(b):
        diff = [i for i, (x, y) in enumerate(zip(a, b)) if x != y]
        if len(diff) == 1:
            return True
        return (
            len(diff) == 2
            and diff[1] == diff[0] + 1
            and a[diff[0]] == b[diff[1]]
            and a[diff[1]] == b[diff[0]]
        )
    long, short = (a, b) if len(a) > len(b) else (b, a)
    i = j = edits = 0
    while i < len(long) and j < len(short):
        if long[i] == short[j]:
            i += 1
            j += 1
        else:
            edits += 1
            if edits > 1:
                return False
            i += 1  # one extra character in `long`
    return True


def state_like(word: str, states: list[str]) -> bool:
    """True if a container heading starting with `word` would be misread as a
    task state: an exact state, or the near-miss rules of the schema."""
    token = word.rstrip(":").lower()
    lowered = [s.lower() for s in states]
    if token in lowered:
        return True
    return any(
        len(state) >= 6 and len(token) >= 6 and near_miss(token, state)
        for state in lowered
    )


def org_file_paths(paths: list[Path]) -> list[Path]:
    """Every *.org and *.org_archive file under the paths, symlinks resolved."""
    seen: set[str] = set()
    found: list[Path] = []
    for root in paths:
        for dirpath, dirs, names in os.walk(root, followlinks=True):
            dirs[:] = [d for d in dirs if d not in ORG_SKIP_DIRS]
            for name in names:
                if not name.endswith((".org", ".org_archive")):
                    continue
                real = os.path.realpath(os.path.join(dirpath, name))
                if real not in seen:
                    seen.add(real)
                    found.append(Path(real))
    return sorted(found)


def org_states(lines: list[str]) -> list[str]:
    """The states declared in the file's own #+TODO: line, or the default pair."""
    for line in lines:
        found = ORG_TODO_LINE.match(line)
        if found:
            return [word for word in found.group(1).split() if word != "|"]
    return ["TODO", "DONE"]


def check_stamps(text: str, line_number: int, errors: list[str], path: Path) -> None:
    """Every timestamp on the line must carry the weekday its date says."""
    for year, month, day, name in ORG_STAMP.findall(text):
        if not name:
            continue
        real = datetime.date(int(year), int(month), int(day)).strftime("%a")
        if real != name:
            column = text.find(f"{year}-{month}-{day} {name}") + 1
            errors.append(
                f"{path}:{line_number}:{column}: day name says {name}, date is {real}"
            )


def scan_org_file(path: Path, config: TodoConfig, *, due_only: bool, today: str) -> tuple[
    list[TodoMatch], list[str]
]:
    """One org file -> (task matches, schema errors). Per the reader conformance."""
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as error:
        return [], [f"{path}:0:0: {error}"]

    states = org_states(text.splitlines())
    declared = set(states)
    excluded = set(config.exclude_patterns)
    matches: list[TodoMatch] = []
    errors: list[str] = []
    inside_blocks: list[str] = []  # block names; nested blocks stack
    pending_task: TodoMatch | None = None
    pending_deadline: str | None = None

    for number, line in enumerate(text.splitlines(), start=1):
        block = ORG_BLOCK.match(line)
        if block:
            if block.group(1) == "BEGIN":
                inside_blocks.append(block.group(2))
            elif inside_blocks and inside_blocks[-1] == block.group(2):
                inside_blocks.pop()
            continue
        if inside_blocks:
            continue

        check_stamps(line, number, errors, path)

        if not line.startswith("*"):
            deadline = ORG_DEADLINE.match(line)
            if deadline and pending_task is not None:
                found = ORG_STAMP.search(line)
                if found:
                    pending_deadline = f"{found.group(1)}-{found.group(2)}-{found.group(3)}"
            if re.match(r"^\s+\*\s+\S", line) and state_like(line.split()[1], config.states):
                errors.append(
                    f"{path}:{number}:{len(line) - len(line.lstrip()) + 1}: "
                    "an indented * with a state keyword is a task that would vanish"
                )
            continue

        heading = ORG_HEADING.match(line)
        if not heading:
            errors.append(f"{path}:{number}:1: bad heading line")
            continue
        # The previous task's window ends here; resolve its due filter first.
        if pending_task is not None:
            if pending_deadline is not None and pending_deadline <= today:
                matches.append(pending_task)
            pending_task, pending_deadline = None, None
        stars, token, rest = heading.groups()
        column = len(stars) + 2
        pending_task, pending_deadline = None, None

        if token in declared:
            if not rest.strip():
                errors.append(f"{path}:{number}:{column}: empty title")
                continue
            match = TodoMatch(
                file=str(path), line=number, column=column, text=line.rstrip()
            )
            # Only outstanding states are reported; DONE/OBSOLETE stay in the file.
            if token not in set(config.patterns):
                continue
            if token in excluded:
                continue
            if due_only:
                pending_task = match  # deadline may follow on the next line
                continue
            matches.append(match)
        elif state_like(token, config.states):
            errors.append(
                f"{path}:{number}:{column}: state-like container heading"
            )
        # else: a plain container heading; carries no task data

    if pending_task is not None:
        if pending_deadline is not None and pending_deadline <= today:
            matches.append(pending_task)

    return matches, errors


def org_scan(
    config: TodoConfig, paths: list[Path], *, due_only: bool
) -> list[TodoMatch]:
    """Scan every org file under the paths. One rejection fails the scan."""
    today = datetime.date.today().isoformat()
    all_matches: list[TodoMatch] = []
    all_errors: list[str] = []
    for path in org_file_paths(paths):
        if drop_ignored_paths([TodoMatch(str(path), 0, 0, "")], config):
            file_matches, file_errors = scan_org_file(
                path, config, due_only=due_only, today=today
            )
            all_matches.extend(file_matches)
            all_errors.extend(file_errors)
    if all_errors:
        raise TodoError("\n".join(all_errors))
    return all_matches


def drop_foreign_mentions(
    matches: list[TodoMatch], others: list[str]
) -> list[TodoMatch]:
    """Drop matches whose text @mentions anyone listed in `others`.

    Every other @tag (e.g. the context tag @writing) is kept.
    """
    names = {name.lower() for name in others}
    kept: list[TodoMatch] = []
    for match in matches:
        mentions = _MENTION_RE.findall(match.text)
        if any(mention.lower() in names for mention in mentions):
            continue
        kept.append(match)
    return kept


def status_regex(config: TodoConfig, entry: str) -> re.Pattern[str]:
    """Compile the regex recognising one status token.

    An entry naming a configured keyword (e.g. ``TODO``) matches ``TODO:`` on a
    word boundary; anything else is treated as the checkbox token.
    """
    if entry in set(config.patterns):
        return re.compile(rf"(?<![A-Za-z0-9_]){re.escape(entry)}:")
    if config.checkbox_patterns:
        return re.compile(alternation(config.checkbox_patterns))
    return re.compile(re.escape(entry))


def leading_status(config: TodoConfig, entries: list[str]):
    """Return a function giving the leftmost of `entries` present in a match.

    This is the line's own marker: a ``- TODO: ... see LATER`` line reports
    ``TODO``. Org headings (`** TODO Fix x`) report their keyword directly.
    Returns None when the text carries none of the entries.
    """
    specs = [(entry, status_regex(config, entry)) for entry in entries]

    def status_of(match: TodoMatch) -> str | None:
        heading = ORG_HEADING.match(match.text)
        if heading and heading.group(2) in set(config.states):
            return heading.group(2)
        best: str | None = None
        best_pos: int | None = None
        for entry, regex in specs:
            found = regex.search(match.text)
            if found is None:
                continue
            position = found.start()
            if best_pos is None or position < best_pos:
                best_pos = position
                best = entry
        return best

    return status_of


def flow_ranker(config: TodoConfig):
    """Return a function ranking a match by its status in the kanban flow order.

    A match is ranked by its leading status token, so anything not listed in
    `flow_order` sorts last.
    """
    status_of = leading_status(config, config.flow_order)
    ranks = {entry: rank for rank, entry in enumerate(config.flow_order)}
    last = len(config.flow_order)

    def rank_of(match: TodoMatch) -> int:
        return ranks.get(status_of(match), last)

    return rank_of


def drop_excluded(matches: list[TodoMatch], config: TodoConfig) -> list[TodoMatch]:
    """Drop matches whose leading status token is excluded by configuration."""
    if not config.exclude_patterns:
        return matches
    status_of = leading_status(config, config.patterns + config.checkbox_patterns)
    excluded = set(config.exclude_patterns)
    return [match for match in matches if status_of(match) not in excluded]


DUE_DATE = re.compile(r"\bdue:(\d{4}-\d{2}-\d{2})")


def drop_not_due(matches: list[TodoMatch], today: str | None = None) -> list[TodoMatch]:
    """Keep only matches whose due: date is today or earlier."""
    if today is None:
        today = datetime.date.today().isoformat()

    def is_due(match: TodoMatch) -> bool:
        found = DUE_DATE.search(match.text)
        # ISO dates compare correctly as strings.
        return found is not None and found.group(1) <= today

    return [match for match in matches if is_due(match)]


def scan(
    config: TodoConfig,
    paths: list[Path],
    *,
    all_extensions: bool = False,
    include_excluded: bool = False,
    due_only: bool = False,
) -> list[TodoMatch]:
    if shutil.which("rg") is None:
        raise TodoError("ripgrep (rg) is required")
    markdown_pattern, source_pattern = build_patterns(config)
    # Ignore globs must come after the extension whitelist: ripgrep applies
    # globs last-match-wins, so a trailing "*.md" would otherwise re-include
    # everything the "!..." ignore globs excluded.
    ignores = ignore_globs(config)

    markdown_globs: list[str] = []
    for extension in config.extensions:
        markdown_globs.extend(("--glob", f"*.{extension}"))
    markdown_globs.extend(ignores)

    matches = drop_fenced(rg_json(markdown_pattern, markdown_globs, paths))
    source_extensions = [
        extension
        for extension in config.source_extensions
        if extension not in config.extensions
    ]
    if all_extensions and source_extensions:
        source_globs: list[str] = []
        for extension in source_extensions:
            source_globs.extend(("--glob", f"*.{extension}"))
        source_globs.extend(ignores)
        matches.extend(rg_json(source_pattern, source_globs, paths))
    matches = drop_ignored_paths(matches, config)
    matches = drop_foreign_mentions(matches, config.others)
    if not include_excluded:
        matches = drop_excluded(matches, config)
    if due_only:
        matches = drop_not_due(matches)
    matches.extend(org_scan(config, paths, due_only=due_only))
    rank_of = flow_ranker(config)
    return sorted(set(matches), key=lambda match: (rank_of(match), match))


def render_plain(matches: list[TodoMatch]) -> str:
    return "".join(f"{match.vimgrep()}\n" for match in matches)


def markdown_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace("|", r"\|")


def render_markdown(matches: list[TodoMatch]) -> str:
    if not matches:
        return "# Outstanding tasks\n\n_No tasks found._\n"
    lines = ["# Outstanding tasks", "", "| Location | Task |", "|---|---|"]
    for match in matches:
        location = markdown_escape(f"{match.file}:{match.line}")
        lines.append(f"| `{location}` | {markdown_escape(match.text)} |")
    return "\n".join(lines) + "\n"


def open_vim(matches: list[TodoMatch]) -> None:
    if shutil.which("vim") is None:
        raise TodoError("vim is required for --format vim")
    with tempfile.NamedTemporaryFile(
        mode="w", encoding="utf-8", prefix="todo-results.", delete=False
    ) as stream:
        stream.write(render_plain(matches))
        result_path = Path(stream.name)
    try:
        subprocess.run(["vim", "-q", str(result_path), "-c", "copen"], check=False)
    finally:
        result_path.unlink(missing_ok=True)


def open_fzf(matches: list[TodoMatch]) -> None:
    if shutil.which("fzf") is None:
        raise TodoError("fzf is required for --format fzf")
    by_line = {match.vimgrep(): match for match in matches}
    process = subprocess.run(
        ["fzf", "--delimiter=:", "--nth=1,2,4.."],
        input=render_plain(matches),
        capture_output=True,
        check=False,
        text=True,
    )
    selected = process.stdout.rstrip("\r\n")
    match = by_line.get(selected)
    if match is None:
        return
    editor = shlex.split(os.environ.get("EDITOR", "vim"))
    if not editor or shutil.which(editor[0]) is None:
        raise TodoError(f"editor is not executable: {' '.join(editor) or '(empty)'}")
    subprocess.run([*editor, f"+{match.line}", "--", match.file], check=False)


def output(matches: list[TodoMatch], output_format: str, paths: list[Path]) -> None:
    if not matches and output_format in {"vim", "fzf"}:
        joined_paths = " ".join(str(path) for path in paths)
        print(f"No outstanding tasks under: {joined_paths}")
        return
    if output_format == "plain":
        print(render_plain(matches), end="")
    elif output_format == "json":
        print(json.dumps([match.as_dict() for match in matches], indent=2))
    elif output_format == "markdown":
        print(render_markdown(matches), end="")
    elif output_format == "vim":
        open_vim(matches)
    elif output_format == "fzf":
        open_fzf(matches)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    try:
        config = TodoConfig.load(config_path(), local_config_path())
        if args.states:
            print("\n".join(config.states))
            return 0
        paths = existing_paths(args.paths or config.default_dirs)
        matches = scan(
            config,
            paths,
            all_extensions=args.all_extensions,
            include_excluded=args.include_excluded,
            due_only=args.due,
        )
        output(matches, args.format, paths)
    except TodoError as error:
        print(f"todo: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
