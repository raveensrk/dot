#!/usr/bin/env python3

"""End-to-end tests for the Python TODO scanner."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "script" / ",todo.py"


class TodoScannerTest(unittest.TestCase):
    def setUp(self) -> None:
        temporary_directory = tempfile.TemporaryDirectory(prefix="todo-test.")
        self.addCleanup(temporary_directory.cleanup)
        self.fixture = Path(temporary_directory.name)
        (self.fixture / "ignored").mkdir()

        self.write(
            "notes.md",
            """\
            - TODO: Markdown task
              - IN_PROGRESS: Nested task
            - [ ] Checkbox task
            - TODO:
            TODO: not a list item
            Prose mentioning TODO is not a task.
            # TODO: Markdown heading is not a task.
            """,
        )
        self.write(
            "app.py",
            '''\
            # TODO: Python task
            run()  # FIXME: Inline source task
            value = "TODO: string literal"
            # TODO_CONFIG is not a task
            ''',
        )
        self.write(
            "app.js",
            '''\
            // BUG: JavaScript task
            /* LATER: Block comment task */
            const value = "// TODO: string after a quote";
            ''',
        )
        self.write(
            "design.sv",
            '''\
            // BUG: SystemVerilog task
            /* LATER: Refactor testbench task */
            ''',
        )
        self.write("ignored/skip.py", "# TODO: Ignored task\n")
        self.config = self.write_config(
            "todo.toml",
            patterns=["TODO", "IN_PROGRESS", "FIXME", "BUG", "LATER"],
            source_extensions=["py", "sh", "bash", "sv", "svh", "v", "vim"],
            ignore=["ignored", "editor.log", "bin"],
        )

    def write(self, relative_path: str, content: str) -> Path:
        path = self.fixture / relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(textwrap.dedent(content), encoding="utf-8")
        return path

    def write_config(
        self,
        name: str,
        *,
        patterns: list[str],
        checkbox_patterns: list[str] | None = None,
        source_extensions: list[str] | None = None,
        ignore: list[str] | None = None,
        owner_mentions: list[str] | None = None,
        flow_order: list[str] | None = None,
    ) -> Path:
        values = {
            "patterns": patterns,
            "checkbox_patterns": (
                [r"\[ \]"] if checkbox_patterns is None else checkbox_patterns
            ),
            "extensions": ["md"],
            "source_extensions": source_extensions or [],
            "default_dirs": [str(self.fixture)],
            "ignore": ignore or ["ignored"],
            "owner_mentions": (
                ["raveen", "raveensrk", "raveenkumar", "raveen_kumar", "raveen-kumar"]
                if owner_mentions is None
                else owner_mentions
            ),
            "flow_order": (
                ["IN_PROGRESS", "TODO", "[ ]", "FIXME", "BUG", "LATER"]
                if flow_order is None
                else flow_order
            ),
        }
        lines = [f"{key} = {json.dumps(value)}" for key, value in values.items()]
        lines.append("comment_prefix_pattern = '//+|#|--|;|/\\*+|\\*+|<!--|%'")
        return self.write(name, "\n".join(lines) + "\n")

    def run_scanner(
        self,
        *arguments: str,
        config: Path | None = None,
        environment: dict[str, str] | None = None,
    ) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env["TODO_CONFIG"] = str(config or self.config)
        if environment:
            env.update(environment)
        return subprocess.run(
            [sys.executable, str(SCRIPT), *arguments],
            capture_output=True,
            check=False,
            env=env,
            text=True,
        )

    def test_default_output_contains_only_markdown_tasks(self) -> None:
        result = self.run_scanner("--format", "plain")
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = [
            "notes.md:1:1:- TODO: Markdown task",
            "notes.md:2:1:  - IN_PROGRESS: Nested task",
            "notes.md:3:1:- [ ] Checkbox task",
        ]
        for match in expected:
            self.assertIn(match, result.stdout)
        for rejected in (
            "notes.md:4:",
            "notes.md:5:",
            "notes.md:6:",
            "notes.md:7:",
            "app.py:",
            "app.js:",
            "design.sv:",
            "ignored/skip.py",
        ):
            self.assertNotIn(rejected, result.stdout)

    def test_all_extensions_adds_only_configured_source_files(self) -> None:
        result = self.run_scanner("--all-extensions", "--format", "plain")
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = [
            "notes.md:1:1:- TODO: Markdown task",
            "notes.md:2:1:  - IN_PROGRESS: Nested task",
            "notes.md:3:1:- [ ] Checkbox task",
            "app.py:1:1:# TODO: Python task",
            "app.py:2:7:run()  # FIXME: Inline source task",
            "design.sv:1:1:// BUG: SystemVerilog task",
            "design.sv:2:1:/* LATER: Refactor testbench task */",
        ]
        for match in expected:
            self.assertIn(match, result.stdout)
        self.assertNotIn("app.js:", result.stdout)
        self.assertNotIn("app.py:3:", result.stdout)
        self.assertNotIn("app.py:4:", result.stdout)

    def test_json_and_markdown_output(self) -> None:
        json_result = self.run_scanner("--format", "json")
        self.assertEqual(json_result.returncode, 0, json_result.stderr)
        matches = json.loads(json_result.stdout)
        self.assertEqual(len(matches), 3)
        self.assertEqual(
            set(matches[0]), {"file", "line", "column", "text"}
        )

        all_json = self.run_scanner("--all-extensions", "--format", "json")
        self.assertEqual(all_json.returncode, 0, all_json.stderr)
        self.assertEqual(len(json.loads(all_json.stdout)), 7)

        markdown = self.run_scanner("--format", "markdown")
        self.assertEqual(markdown.returncode, 0, markdown.stderr)
        self.assertIn("# Outstanding tasks", markdown.stdout)
        self.assertIn("| Location | Task |", markdown.stdout)

    def test_empty_outputs(self) -> None:
        empty = self.fixture / "empty"
        empty.mkdir()
        plain = self.run_scanner("--format", "plain", str(empty))
        json_result = self.run_scanner("--format", "json", str(empty))
        markdown = self.run_scanner("--format", "markdown", str(empty))
        self.assertEqual(plain.stdout, "")
        self.assertEqual(json.loads(json_result.stdout), [])
        self.assertIn("_No tasks found._", markdown.stdout)

    def test_missing_roots_are_skipped(self) -> None:
        result = self.run_scanner(
            "--format",
            "plain",
            str(self.fixture / "does-not-exist"),
            str(self.fixture / "notes.md"),
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("- TODO: Markdown task", result.stdout)
        self.assertIn("skipping missing path", result.stderr)

    def test_checkboxes_can_be_disabled(self) -> None:
        config = self.write_config(
            "no-checkboxes.toml", patterns=["TODO"], checkbox_patterns=[]
        )
        result = self.run_scanner(
            "--format", "plain", str(self.fixture / "notes.md"), config=config
        )
        self.assertIn("- TODO: Markdown task", result.stdout)
        self.assertNotIn("- [ ] Checkbox task", result.stdout)

    def test_fenced_code_blocks_are_ignored(self) -> None:
        self.write(
            "fenced.md",
            """\
            - TODO: real task before fence
            ```
            - TODO: fenced task ignored
            ```
            ~~~md
            - [ ] fenced checkbox ignored
            ~~~
            - FIXME: real task after fence
            """,
        )
        result = self.run_scanner(
            "--format", "plain", str(self.fixture / "fenced.md")
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("- TODO: real task before fence", result.stdout)
        self.assertIn("- FIXME: real task after fence", result.stdout)
        self.assertNotIn("fenced task ignored", result.stdout)
        self.assertNotIn("fenced checkbox ignored", result.stdout)

    def test_foreign_mentions_are_ignored(self) -> None:
        self.write(
            "mentions.md",
            """\
            - TODO: assigned to someone else @Sakthi
            - TODO: mine lowercase @raveen
            - TODO: mine mixed case @Raveen_Kumar
            - TODO: mine hyphen @raveen-kumar
            - TODO: unassigned task with no mention
            """,
        )
        result = self.run_scanner(
            "--format", "plain", str(self.fixture / "mentions.md")
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("@Sakthi", result.stdout)
        self.assertIn("mine lowercase @raveen", result.stdout)
        self.assertIn("mine mixed case @Raveen_Kumar", result.stdout)
        self.assertIn("mine hyphen @raveen-kumar", result.stdout)
        self.assertIn("unassigned task with no mention", result.stdout)

    def test_owner_mentions_are_configurable(self) -> None:
        config = self.write_config(
            "custom-owner.toml", patterns=["TODO"], owner_mentions=["alice"]
        )
        self.write(
            "custom.md",
            """\
            - TODO: for alice @alice
            - TODO: for raveen @raveen
            """,
        )
        result = self.run_scanner(
            "--format", "plain", str(self.fixture / "custom.md"), config=config
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("for alice @alice", result.stdout)
        self.assertNotIn("@raveen", result.stdout)

    def test_local_overlay_appends_ignore_and_overrides_keys(self) -> None:
        base = self.write_config("base.toml", patterns=["TODO"], ignore=["ignored"])
        self.write("local.toml", 'ignore = ["private"]\npatterns = ["TODO", "BUG"]\n')
        self.write("ignored/skip.md", "- TODO: base-ignored task\n")
        self.write("private/skip.md", "- TODO: locally ignored task\n")
        self.write("keep.md", "- TODO: kept task\n- BUG: local-only keyword\n")
        result = self.run_scanner(
            "--format",
            "plain",
            str(self.fixture),
            config=base,
            environment={"TODO_CONFIG_LOCAL": str(self.fixture / "local.toml")},
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        # Overlay `ignore` is appended to the base one: both dirs excluded.
        self.assertNotIn("base-ignored task", result.stdout)
        self.assertNotIn("locally ignored task", result.stdout)
        self.assertIn("- TODO: kept task", result.stdout)
        # Overlay replaces `patterns`, so the local-only BUG keyword is matched.
        self.assertIn("- BUG: local-only keyword", result.stdout)

    def test_flow_order_sorts_by_status(self) -> None:
        self.write(
            "flow.md",
            """\
            - LATER: do later thing
            - [ ] checkbox thing
            - IN_PROGRESS: doing now
            - TODO: to do thing
            - FIXME: fix this
            """,
        )
        result = self.run_scanner(
            "--format", "plain", str(self.fixture / "flow.md")
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        texts = [line.split(":", 3)[3] for line in result.stdout.splitlines()]
        self.assertEqual(
            texts,
            [
                "- IN_PROGRESS: doing now",
                "- TODO: to do thing",
                "- [ ] checkbox thing",
                "- FIXME: fix this",
                "- LATER: do later thing",
            ],
        )

    def test_empty_flow_order_falls_back_to_file_sort(self) -> None:
        config = self.write_config(
            "no-flow.toml",
            patterns=["TODO", "IN_PROGRESS", "FIXME", "LATER"],
            flow_order=[],
        )
        self.write(
            "flow2.md",
            """\
            - LATER: do later thing
            - IN_PROGRESS: doing now
            - TODO: to do thing
            """,
        )
        result = self.run_scanner(
            "--format", "plain", str(self.fixture / "flow2.md"), config=config
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        texts = [line.split(":", 3)[3] for line in result.stdout.splitlines()]
        self.assertEqual(
            texts,
            [
                "- LATER: do later thing",
                "- IN_PROGRESS: doing now",
                "- TODO: to do thing",
            ],
        )

    def test_source_extensions_can_be_restricted(self) -> None:
        config = self.write_config(
            "python-only.toml",
            patterns=["TODO", "FIXME", "BUG", "LATER"],
            source_extensions=["py"],
        )
        result = self.run_scanner(
            "--all-extensions", "--format", "plain", config=config
        )
        self.assertIn("app.py:1:1:# TODO: Python task", result.stdout)
        self.assertNotIn("app.js:", result.stdout)

    def test_direct_source_file_requires_all_extensions(self) -> None:
        source_file = str(self.fixture / "app.py")
        default = self.run_scanner("--format", "plain", source_file)
        enabled = self.run_scanner(
            "--all-extensions", "--format", "plain", source_file
        )
        self.assertEqual(default.stdout, "")
        self.assertIn("# TODO: Python task", enabled.stdout)

    def test_empty_source_extensions_scan_no_source_files(self) -> None:
        config = self.write_config(
            "markdown-only.toml",
            patterns=["TODO", "FIXME"],
            source_extensions=[],
        )
        result = self.run_scanner(
            "--all-extensions",
            "--format",
            "plain",
            str(self.fixture / "app.py"),
            config=config,
        )
        self.assertEqual(result.stdout, "")

    def test_markdown_extensions_are_never_scanned_as_source(self) -> None:
        config = self.write_config(
            "overlap.toml",
            patterns=["TODO"],
            source_extensions=["md"],
        )
        result = self.run_scanner(
            "--all-extensions",
            "--format",
            "plain",
            str(self.fixture / "notes.md"),
            config=config,
        )
        self.assertNotIn("Markdown heading is not a task", result.stdout)

    def test_fzf_and_vim_launch_python_stubs(self) -> None:
        binary_directory = self.fixture / "bin"
        binary_directory.mkdir()
        fzf = self.write(
            "bin/fzf",
            """\
            #!/usr/bin/env python3
            import sys
            print(sys.stdin.readline(), end="")
            """,
        )
        editor = self.write(
            "bin/editor",
            """\
            #!/usr/bin/env python3
            import json
            import os
            import sys
            with open(os.environ["EDITOR_LOG"], "w", encoding="utf-8") as stream:
                json.dump(sys.argv[1:], stream)
            """,
        )
        vim = self.write(
            "bin/vim",
            """\
            #!/usr/bin/env python3
            import json
            import os
            import sys
            with open(os.environ["VIM_LOG"], "w", encoding="utf-8") as stream:
                json.dump(sys.argv[1:], stream)
            """,
        )
        for executable in (fzf, editor, vim):
            executable.chmod(0o755)

        path = f"{binary_directory}{os.pathsep}{os.environ['PATH']}"
        editor_log = self.fixture / "editor.log"
        fzf_result = self.run_scanner(
            "--format",
            "fzf",
            environment={
                "PATH": path,
                "EDITOR": str(editor),
                "EDITOR_LOG": str(editor_log),
            },
        )
        self.assertEqual(fzf_result.returncode, 0, fzf_result.stderr)
        editor_arguments = json.loads(editor_log.read_text(encoding="utf-8"))
        # Flow order puts IN_PROGRESS (notes.md line 2) first in the list.
        self.assertEqual(editor_arguments[0], "+2")
        self.assertIn("--", editor_arguments)
        self.assertTrue(editor_arguments[-1].endswith("notes.md"))

        vim_log = self.fixture / "vim.log"
        vim_result = self.run_scanner(
            environment={"PATH": path, "VIM_LOG": str(vim_log)}
        )
        self.assertEqual(vim_result.returncode, 0, vim_result.stderr)
        vim_arguments = json.loads(vim_log.read_text(encoding="utf-8"))
        self.assertEqual(vim_arguments[0], "-q")
        self.assertEqual(vim_arguments[-2:], ["-c", "copen"])

    def test_invalid_configuration_is_rejected(self) -> None:
        invalid = self.write("invalid.toml", "unknown = true\n")
        result = self.run_scanner("--format", "plain", config=invalid)
        self.assertEqual(result.returncode, 2)
        self.assertIn("unknown configuration keys", result.stderr)


if __name__ == "__main__":
    unittest.main()
