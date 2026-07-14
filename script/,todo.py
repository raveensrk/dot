#!/usr/bin/env python3

"""Scan Markdown tasks and source comments with ripgrep."""

from __future__ import annotations

import argparse
import base64
import json
import os
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
    extensions: list[str] = field(default_factory=lambda: ["md"])
    source_extensions: list[str] = field(default_factory=list)
    default_dirs: list[str] = field(default_factory=lambda: ["."])
    ignore: list[str] = field(default_factory=list)
    comment_prefix_pattern: str = r'//+|#|--|;|/\*+|\*+|<!--|%'

    @classmethod
    def load(cls, path: Path | None) -> TodoConfig:
        config = cls()
        if path is None or not path.is_file():
            return config

        try:
            with path.open("rb") as stream:
                values = tomllib.load(stream)
        except (OSError, tomllib.TOMLDecodeError) as error:
            raise TodoError(f"cannot read configuration {path}: {error}") from error

        known_fields = {
            "patterns",
            "checkbox_patterns",
            "extensions",
            "source_extensions",
            "default_dirs",
            "ignore",
            "comment_prefix_pattern",
        }
        unknown = sorted(set(values) - known_fields)
        if unknown:
            raise TodoError(f"unknown configuration keys: {', '.join(unknown)}")

        for name in known_fields - {"comment_prefix_pattern"}:
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


def expand_path(value: str) -> Path:
    return Path(os.path.expandvars(value)).expanduser()


def existing_paths(values: list[str]) -> list[Path]:
    paths: list[Path] = []
    for value in values:
        path = expand_path(value)
        if path.exists():
            paths.append(path)
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


def ignore_globs(config: TodoConfig) -> list[str]:
    globs: list[str] = []
    for pattern in config.ignore:
        if "/" in pattern and not pattern.startswith(("/", "**")):
            pattern = f"**/{pattern}"
        globs.extend(("--glob", f"!{pattern}"))
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


def scan(
    config: TodoConfig, paths: list[Path], *, all_extensions: bool = False
) -> list[TodoMatch]:
    if shutil.which("rg") is None:
        raise TodoError("ripgrep (rg) is required")
    markdown_pattern, source_pattern = build_patterns(config)
    common_globs = ignore_globs(config)

    markdown_globs = list(common_globs)
    for extension in config.extensions:
        markdown_globs.extend(("--glob", f"*.{extension}"))

    matches = rg_json(markdown_pattern, markdown_globs, paths)
    source_extensions = [
        extension
        for extension in config.source_extensions
        if extension not in config.extensions
    ]
    if all_extensions and source_extensions:
        source_globs = list(common_globs)
        for extension in source_extensions:
            source_globs.extend(("--glob", f"*.{extension}"))
        matches.extend(rg_json(source_pattern, source_globs, paths))
    return sorted(set(matches))


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
        config = TodoConfig.load(config_path())
        paths = existing_paths(args.paths or config.default_dirs)
        matches = scan(config, paths, all_extensions=args.all_extensions)
        output(matches, args.format, paths)
    except TodoError as error:
        print(f"todo: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
