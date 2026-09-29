"""Run: python3 -m unittest discover -s tests -p test_agent_config.py"""

import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location("agent_config", Path(__file__).parents[1] / "script/,agent_config.py")
skills = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(skills)


class SkillsTest(unittest.TestCase):
    def test_export(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()) as output:
            agent = Path(tmp).resolve()
            source = agent / "settings.json"
            target = agent / "settings.example.json"
            backup = agent / "settings.example.json.bak.skills"
            local = {"defaultProvider": "private", "defaultModel": "private-model",
                     "skills": ["/private/skill"], "lastChangelogVersion": "1.0",
                     "theme": "light", "packages": ["npm:example"], "powerline": {"preset": "default"}}
            source.write_text(json.dumps(local))
            original = source.read_bytes()
            target.write_text('{"theme":"dark","obsolete":true,"defaultModel":"old"}\n')
            saved = target.read_bytes()
            skills.export(agent)
            self.assertEqual(target.read_bytes(), saved)
            self.assertFalse(backup.exists())
            self.assertNotIn("private-model", output.getvalue())
            self.assertNotIn("/private/skill", output.getvalue())

            # Exercise CLI dispatch without any scan roots present.
            with patch.dict(skills.os.environ, {"PI_CODING_AGENT_DIR": str(agent), "XDG_STATE_HOME": str(agent / "state")}), patch.object(skills.sys, "argv", [",agent_config.py", "--export", "--apply"]):
                skills.main()
            expected = {k: v for k, v in local.items() if k not in skills.LOCAL}
            self.assertEqual(json.loads(target.read_text()), expected)
            self.assertEqual(backup.read_bytes(), saved)
            self.assertEqual(source.read_bytes(), original)
            stamps = [(p.read_bytes(), p.stat().st_mtime_ns) for p in (source, target, backup)]
            skills.export(agent, apply=True)
            self.assertEqual(stamps, [(p.read_bytes(), p.stat().st_mtime_ns) for p in (source, target, backup)])

            source.unlink()
            with self.assertRaises(FileNotFoundError):
                skills.export(agent, apply=True)
            source.write_text("[]")
            with self.assertRaisesRegex(ValueError, "expected JSON object"):
                skills.export(agent, apply=True)
            self.assertEqual(json.loads(target.read_text()), expected)
            source.write_bytes(original)
            target.unlink()
            skills.export(agent, apply=True)
            self.assertEqual(json.loads(target.read_text()), expected)
            target.unlink()
            target.symlink_to(source)
            with self.assertRaisesRegex(ValueError, "different files"):
                skills.export(agent, apply=True)
            self.assertEqual(source.read_bytes(), original)

    def test_tree(self):
        output = io.StringIO()
        with patch.object(Path, "home", return_value=Path("/home/test")), contextlib.redirect_stdout(output):
            skills.log("skip", source="/home/test/repos/local", reason="not explicitly global")
            skills.log("keep", name="review", source="/home/test/repos/review", destination="settings.json")
            skills.log("register", name="new", source="/home/test/repos/new")
            skills.log("remove", source="/outside/old", reason="no longer global")
            skills.log("unlink", path="/home/test/.agents/skills/review", source="/home/test/repos/review", reason="native path")
            skills.log("preview", globals=2, added=1, removed=1, links=1)
        self.assertEqual(output.getvalue(), (
            "|-- [SKIP] ~/repos/local\n"
            "|   `-- Reason: not explicitly global\n"
            "|-- [KEEP] review\n"
            "|   `-- Source: ~/repos/review\n"
            "|-- [ADD] new\n"
            "|   `-- Source: ~/repos/new\n"
            "|-- [REMOVE] /outside/old\n"
            "|   `-- Reason: no longer global\n"
            "|-- [MIGRATE] ~/.agents/skills/review\n"
            "|   |-- Source: ~/repos/review\n"
            "|   `-- Reason: native path\n"
            "`-- Summary: 2 global, 1 to add, 1 to remove, 1 links to migrate\n"
        ))
        error = io.StringIO()
        with contextlib.redirect_stderr(error):
            skills.log("error", message="invalid settings")
        self.assertEqual(error.getvalue(), "ERROR: invalid settings\n")

    def test_sync(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()):
            root = Path(tmp).resolve()
            repos = root / "repos"
            repos.mkdir()
            agent = root / "agent"
            agent.mkdir()
            shared = root / "shared"
            shared.mkdir()
            state = root / "state.json"
            settings = agent / "settings.json"

            def skill(folder, name, scope="global"):
                path = repos / folder
                path.mkdir(parents=True, exist_ok=True)
                (path / "SKILL.md").write_text(
                    f"---\nname: {name}\ndescription: Test skill.\nmetadata:\n  scope: {scope}\n---\n"
                )
                return path

            source = skill("nested/global", "global")
            manual = skill("manual", "manual")
            skill("local", "local", "local")
            skill("node_modules/dependency", "global")
            hidden = skill(".claude/skills/hidden", "hidden")
            (repos / "alias").symlink_to(source, target_is_directory=True)
            link = shared / "global"
            link.symlink_to(source, target_is_directory=True)
            unrelated = shared / "unrelated"
            unrelated.symlink_to(repos / "local", target_is_directory=True)
            (shared / "real").mkdir()
            initial = {"skills": [str(manual), "!**/disabled/**"], "packages": ["npm:keep"], "custom": {"keep": True}}
            original = json.dumps(initial)
            settings.write_text(original)

            def run(apply=True):
                skills.sync([repos], agent, shared, state, apply)

            run(False)
            self.assertEqual(settings.read_text(), original)
            self.assertFalse(state.exists())
            self.assertTrue(link.is_symlink())
            self.assertFalse((agent / "settings.json.bak.skills").exists())

            run()
            cfg = json.loads(settings.read_text())
            self.assertEqual(cfg["skills"], initial["skills"] + sorted([str(source), str(hidden)]))
            self.assertEqual(cfg["packages"], initial["packages"])
            self.assertEqual(cfg["custom"], initial["custom"])
            self.assertEqual((agent / "settings.json.bak.skills").read_text(), original)
            self.assertEqual(set(json.loads(state.read_text())["paths"]), {str(source), str(hidden)})
            self.assertFalse(link.is_symlink())
            self.assertTrue(unrelated.is_symlink())
            self.assertTrue((shared / "real").is_dir())
            stamps = [p.stat().st_mtime_ns for p in (settings, state)]
            run()
            self.assertEqual(stamps, [p.stat().st_mtime_ns for p in (settings, state)])

            # Duplicate globals fail before writes or migration.
            duplicate = skill("duplicate", "global")
            before = settings.read_bytes(), state.read_bytes()
            with self.assertRaisesRegex(ValueError, "duplicate skill"):
                run()
            self.assertEqual(before, (settings.read_bytes(), state.read_bytes()))
            (duplicate / "SKILL.md").unlink()

            # Missing roots and malformed metadata must not trigger pruning.
            with self.assertRaisesRegex(ValueError, "scan root missing"):
                skills.sync([root / "missing"], agent, shared, state, True)
            (duplicate / "SKILL.md").write_text("---\nmetadata: [\n---\n")
            with self.assertRaises(ValueError):
                run()
            self.assertEqual(before, (settings.read_bytes(), state.read_bytes()))
            (duplicate / "SKILL.md").unlink()

            # Losing global scope/removing source prunes only owned entries.
            skill("nested/global", "global", "local")
            skill("manual", "manual", "local")
            (hidden / "SKILL.md").unlink()
            run()
            self.assertEqual(json.loads(settings.read_text()), initial)
            self.assertEqual(json.loads(state.read_text())["paths"], [])

            # Interrupted config writes retain ownership; retry finishes safely.
            skill("nested/global", "global")
            link.symlink_to(source, target_is_directory=True)
            atomic = skills.atomic

            def fail(path, content):
                if path == settings:
                    raise OSError("simulated write failure")
                atomic(path, content)

            with patch.object(skills, "atomic", side_effect=fail):
                with self.assertRaisesRegex(OSError, "simulated"):
                    run()
            self.assertTrue(link.is_symlink())
            self.assertEqual(json.loads(settings.read_text()), initial)
            run()
            self.assertIn(str(source), json.loads(settings.read_text())["skills"])
            self.assertFalse(link.is_symlink())

            # A manually rewritten spelling becomes manual, not ours to prune.
            cfg = json.loads(settings.read_text())
            cfg["skills"].remove(str(source))
            cfg["skills"].append("+" + str(source))
            settings.write_text(json.dumps(cfg))
            run()
            self.assertEqual(json.loads(state.read_text())["paths"], [])
            skill("nested/global", "global", "local")
            run()
            self.assertIn("+" + str(source), json.loads(settings.read_text())["skills"])
            skill("nested/global", "global")

            # Preserve a symlinked settings file and equivalent manual paths.
            backing = agent / "backing.json"
            settings.rename(backing)
            settings.symlink_to(backing)
            state.unlink()
            backing.write_text(json.dumps({"skills": ["../repos/nested/global"]}))
            run()
            self.assertTrue(settings.is_symlink())
            self.assertEqual(json.loads(backing.read_text())["skills"], ["../repos/nested/global"])
            self.assertEqual(json.loads(state.read_text())["paths"], [])


if __name__ == "__main__":
    unittest.main()
