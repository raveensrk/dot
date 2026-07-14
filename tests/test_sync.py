import importlib.util
import io
import os
import shutil
import subprocess
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest import mock


SCRIPT = Path(__file__).parents[1] / "script" / ",sync.py"
SPEC = importlib.util.spec_from_file_location("sync", SCRIPT)
sync = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(sync)


class SyncTestCase(unittest.TestCase):
    def setUp(self):
        sync.reset_counts()
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.repo = Path(self.temporary_directory.name)

    def tearDown(self):
        self.temporary_directory.cleanup()

    def automatic_responses(self, **overrides):
        responses = {
            "inside": (0, "true", ""),
            "branch": (0, "main", ""),
            "upstream": (0, "backup/trunk", ""),
            "remote": (0, "backup", ""),
            "merge_ref": (0, "refs/heads/trunk", ""),
            "fetch": (0, "", ""),
            "status": (0, "", ""),
            "comparison": (0, "0 0", ""),
            "push": (0, "", ""),
            "merge": (0, "", ""),
        }
        responses.update(overrides)

        def run_git(repo, *args, capture=True):
            command = tuple(args)
            if command == ("rev-parse", "--is-inside-work-tree"):
                return responses["inside"]
            if command == ("branch", "--show-current"):
                return responses["branch"]
            if command == ("config", "--get", "branch.main.remote"):
                return responses["remote"]
            if command == ("config", "--get", "branch.main.merge"):
                return responses["merge_ref"]
            if command == ("fetch", "backup"):
                return responses["fetch"]
            if command == (
                "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"
            ):
                return responses["upstream"]
            if command == ("status", "--porcelain"):
                return responses["status"]
            if command == (
                "rev-list", "--left-right", "--count", "HEAD...backup/trunk"
            ):
                return responses["comparison"]
            if command == ("push", "backup", "HEAD:refs/heads/trunk"):
                return responses["push"]
            if command == ("merge", "--ff-only", "backup/trunk"):
                return responses["merge"]
            raise AssertionError(f"Unexpected Git command: {command}")

        return run_git


class ManualModeTest(SyncTestCase):
    def test_manual_mode_opens_lazygit_without_sync_commands(self):
        def repository_check(repo, *args, capture=True):
            self.assertEqual(args, ("rev-parse", "--is-inside-work-tree"))
            return 0, "true", ""

        with mock.patch.object(sync, "git", side_effect=repository_check) as git, \
                mock.patch.object(sync, "open_lazygit", return_value=0) as lazygit:
            sync.sync_repo(self.repo, manual=True)

        lazygit.assert_called_once_with(str(self.repo))
        self.assertEqual(git.call_count, 1)
        self.assertEqual(sync.counts["manual"], 1)

    def test_manual_mode_skips_non_git_directories(self):
        with mock.patch.object(sync, "git", return_value=(128, "", "not a repository")), \
                mock.patch.object(sync, "open_lazygit") as lazygit:
            sync.sync_repo(self.repo, manual=True)

        lazygit.assert_not_called()
        self.assertEqual(sum(sync.counts.values()), 0)

    def test_manual_mode_reports_lazygit_failure(self):
        with mock.patch.object(sync, "git", return_value=(0, "true", "")), \
                mock.patch.object(sync, "open_lazygit", return_value=1):
            sync.sync_repo(self.repo, manual=True)

        self.assertEqual(sync.counts["manual"], 0)
        self.assertEqual(sync.counts["failed"], 1)

    def test_repository_check_timeout_is_a_failure(self):
        with mock.patch.object(
            sync, "git", return_value=(124, "", "Git command timed out")
        ):
            sync.sync_repo(self.repo, manual=True)

        self.assertEqual(sync.counts["failed"], 1)


class AutomaticModeTest(SyncTestCase):
    def run_sync(self, **overrides):
        git = mock.Mock(side_effect=self.automatic_responses(**overrides))
        output = io.StringIO()
        with mock.patch.object(sync, "git", git), redirect_stdout(output):
            sync.sync_repo(self.repo)
        return git, output.getvalue()

    def test_up_to_date_repository(self):
        git, output = self.run_sync()

        self.assertEqual(sync.counts["ok"], 1)
        self.assertIn("Already up to date", output)
        git.assert_any_call(str(self.repo), "fetch", "backup")

    def test_ahead_repository_pushes_to_configured_upstream(self):
        git, _ = self.run_sync(comparison=(0, "2 0", ""))

        self.assertEqual(sync.counts["pushed"], 1)
        git.assert_any_call(str(self.repo), "push", "backup", "HEAD:refs/heads/trunk")

    def test_behind_repository_fast_forwards_without_push(self):
        git, output = self.run_sync(comparison=(0, "0 3", ""))

        self.assertEqual(sync.counts["synced"], 1)
        self.assertIn("Fast-forwarded by 3", output)
        git.assert_any_call(str(self.repo), "merge", "--ff-only", "backup/trunk")
        self.assertFalse(any(call.args[1] == "push" for call in git.call_args_list))

    def test_diverged_repository_opens_lazygit(self):
        with mock.patch.object(sync, "open_lazygit", return_value=0) as lazygit:
            self.run_sync(comparison=(0, "2 3", ""))

        lazygit.assert_called_once_with(str(self.repo))
        self.assertEqual(sync.counts["attention"], 1)

    def test_missing_upstream_opens_lazygit(self):
        with mock.patch.object(sync, "open_lazygit", return_value=0):
            self.run_sync(remote=(1, "", "no upstream configured"))

        self.assertEqual(sync.counts["attention"], 1)

    def test_branch_command_failure_is_reported(self):
        _, output = self.run_sync(branch=(124, "", "command timed out"))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertEqual(sync.counts["attention"], 0)
        self.assertIn("Branch check failed", output)

    def test_upstream_configuration_command_failure_is_reported(self):
        _, output = self.run_sync(remote=(2, "", "configuration is invalid"))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertEqual(sync.counts["attention"], 0)
        self.assertIn("Upstream configuration check failed", output)

    def test_unresolvable_upstream_after_fetch_is_a_failure(self):
        _, output = self.run_sync(upstream=(128, "", "unknown revision"))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertIn("Could not resolve upstream branch", output)

    def test_fetch_failure_is_reported(self):
        _, output = self.run_sync(fetch=(1, "", "network is unreachable"))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertIn("network unreachable", output)

    def test_status_failure_is_not_treated_as_clean(self):
        _, output = self.run_sync(status=(1, "", "index is corrupt"))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertEqual(sync.counts["ok"], 0)
        self.assertIn("Status check failed", output)

    def test_comparison_failure_is_not_treated_as_up_to_date(self):
        _, output = self.run_sync(comparison=(128, "", "bad revision"))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertEqual(sync.counts["ok"], 0)
        self.assertIn("Upstream comparison failed", output)

    def test_invalid_comparison_output_is_a_failure(self):
        self.run_sync(comparison=(0, "invalid", ""))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertEqual(sync.counts["ok"], 0)

    def test_dirty_repository_opens_lazygit(self):
        with mock.patch.object(sync, "open_lazygit", return_value=0):
            self.run_sync(status=(0, " M file1\n?? file2", ""))

        self.assertEqual(sync.counts["attention"], 1)

    def test_failed_fast_forward_opens_lazygit(self):
        with mock.patch.object(sync, "open_lazygit", return_value=0):
            self.run_sync(
                comparison=(0, "0 1", ""),
                merge=(1, "", "not possible to fast-forward"),
            )

        self.assertEqual(sync.counts["attention"], 1)
        self.assertEqual(sync.counts["synced"], 0)

    def test_failed_lazygit_is_counted_as_failure_not_attention(self):
        with mock.patch.object(sync, "open_lazygit", return_value=1):
            self.run_sync(comparison=(0, "1 1", ""))

        self.assertEqual(sync.counts["failed"], 1)
        self.assertEqual(sync.counts["attention"], 0)


class GitCommandTest(unittest.TestCase):
    def test_git_is_noninteractive_and_has_a_timeout(self):
        completed = subprocess.CompletedProcess([], 0, "output\n", "")
        with mock.patch.object(sync.subprocess, "run", return_value=completed) as run:
            result = sync.git("/repo", "status")

        self.assertEqual(result, (0, "output", ""))
        self.assertEqual(run.call_args.kwargs["timeout"], sync.GIT_TIMEOUT_SECONDS)
        self.assertEqual(run.call_args.kwargs["env"]["GIT_TERMINAL_PROMPT"], "0")

    def test_git_timeout_has_a_structured_result(self):
        timeout = subprocess.TimeoutExpired(["git"], sync.GIT_TIMEOUT_SECONDS)
        with mock.patch.object(sync.subprocess, "run", side_effect=timeout):
            rc, stdout, stderr = sync.git("/repo", "fetch")

        self.assertEqual(rc, 124)
        self.assertEqual(stdout, "")
        self.assertIn("timed out", stderr)


class RepositoryCollectionTest(unittest.TestCase):
    def setUp(self):
        sync.reset_counts()

    def test_relative_environment_and_scanned_paths_are_collected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lists = root / "lists"
            listed_repo = root / "listed"
            environment_repo = root / "environment"
            scanned_repo = root / "scan" / "nested"
            lists.mkdir()
            listed_repo.mkdir()
            environment_repo.mkdir()
            scanned_repo.mkdir(parents=True)
            (scanned_repo / ".git").write_text("gitdir: elsewhere\n")
            repo_list = lists / "repos.txt"
            repo_list.write_text(
                "../listed\n$SYNC_TEST_REPO\ndir: ../scan\n",
            )

            with mock.patch.dict(os.environ, {"SYNC_TEST_REPO": str(environment_repo)}):
                repos = sync.collect_repos([repo_list], [])

        resolved = set(sync.dedup(repos))
        self.assertEqual(
            resolved,
            {str(listed_repo.resolve()), str(environment_repo.resolve()), str(scanned_repo.resolve())},
        )

    def test_missing_sources_are_counted_as_failures(self):
        with tempfile.TemporaryDirectory() as directory, redirect_stdout(io.StringIO()):
            root = Path(directory)
            sync.collect_repos([root / "missing.txt"], [root / "missing-dir"])

        self.assertEqual(sync.counts["failed"], 2)


@unittest.skipUnless(shutil.which("git"), "Git is required for integration tests")
class LocalGitIntegrationTest(unittest.TestCase):
    def setUp(self):
        sync.reset_counts()
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        self.remote = self.root / "remote.git"
        self.seed = self.root / "seed"
        self.repo = self.root / "repo"

        self.run_git("init", "--bare", "--initial-branch=main", str(self.remote))
        self.run_git("init", "--initial-branch=main", str(self.seed))
        self.configure_identity(self.seed)
        (self.seed / "file.txt").write_text("first\n")
        self.run_git("-C", str(self.seed), "add", "file.txt")
        self.run_git("-C", str(self.seed), "commit", "-m", "first")
        self.run_git("-C", str(self.seed), "remote", "add", "origin", str(self.remote))
        self.run_git("-C", str(self.seed), "push", "--set-upstream", "origin", "main")
        self.run_git("clone", str(self.remote), str(self.repo))
        self.configure_identity(self.repo)

    def tearDown(self):
        self.temporary_directory.cleanup()

    @staticmethod
    def run_git(*args):
        return subprocess.run(
            ["git", *args], check=True, capture_output=True, text=True
        ).stdout.strip()

    def configure_identity(self, repo):
        self.run_git("-C", str(repo), "config", "user.name", "Sync Test")
        self.run_git("-C", str(repo), "config", "user.email", "sync@example.invalid")

    def test_behind_repository_is_fast_forwarded(self):
        (self.seed / "file.txt").write_text("second\n")
        self.run_git("-C", str(self.seed), "commit", "-am", "second")
        self.run_git("-C", str(self.seed), "push")

        with redirect_stdout(io.StringIO()), \
                mock.patch.object(sync, "open_lazygit") as lazygit:
            sync.sync_repo(self.repo)

        local_head = self.run_git("-C", str(self.repo), "rev-parse", "HEAD")
        remote_head = self.run_git("--git-dir", str(self.remote), "rev-parse", "refs/heads/main")
        self.assertEqual(local_head, remote_head)
        self.assertEqual(sync.counts["synced"], 1)
        lazygit.assert_not_called()

    def test_ahead_repository_is_pushed(self):
        (self.repo / "local.txt").write_text("local\n")
        self.run_git("-C", str(self.repo), "add", "local.txt")
        self.run_git("-C", str(self.repo), "commit", "-m", "local")

        with redirect_stdout(io.StringIO()), \
                mock.patch.object(sync, "open_lazygit") as lazygit:
            sync.sync_repo(self.repo)

        local_head = self.run_git("-C", str(self.repo), "rev-parse", "HEAD")
        remote_head = self.run_git("--git-dir", str(self.remote), "rev-parse", "refs/heads/main")
        self.assertEqual(local_head, remote_head)
        self.assertEqual(sync.counts["pushed"], 1)
        lazygit.assert_not_called()


class MainExitStatusTest(unittest.TestCase):
    def test_main_resets_counts_and_returns_meaningful_status(self):
        cases = (("ok", 0), ("attention", 2), ("failed", 1))
        for outcome, expected in cases:
            with self.subTest(outcome=outcome):
                sync.counts["failed"] = 99

                def process(repo, manual=False):
                    sync.counts[outcome] += 1

                with mock.patch.object(sync, "collect_repos", return_value=["/repo"]), \
                        mock.patch.object(sync, "dedup", side_effect=lambda repos: repos), \
                        mock.patch.object(sync, "sync_repo", side_effect=process), \
                        mock.patch.object(sync.sys, "argv", ["sync.py", "--file", "repos.txt"]), \
                        redirect_stdout(io.StringIO()):
                    result = sync.main()

                self.assertEqual(result, expected)
                self.assertNotEqual(sync.counts["failed"], 99)


if __name__ == "__main__":
    unittest.main()
