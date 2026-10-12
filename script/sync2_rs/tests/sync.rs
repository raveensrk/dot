//! Integration tests: a bare remote and clones in a temp HOME, one case each.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use assert_cmd::cargo::cargo_bin_cmd;
use tempfile::TempDir;

struct Fixture {
    home: TempDir,
}

impl Fixture {
    fn new() -> Self {
        let f = Fixture {
            home: TempDir::new().unwrap(),
        };
        fs::create_dir_all(f.work()).unwrap();
        fs::create_dir_all(f.path("remotes")).unwrap();
        f
    }

    fn path(&self, rel: &str) -> PathBuf {
        self.home.path().join(rel)
    }

    fn work(&self) -> PathBuf {
        self.path("work")
    }

    fn git(&self, dir: &Path, args: &[&str]) -> String {
        let out = Command::new("git")
            .arg("-C")
            .arg(dir)
            .args(args)
            .env("HOME", self.home.path())
            .env("GIT_CONFIG_NOSYSTEM", "1")
            .env("GIT_AUTHOR_NAME", "t")
            .env("GIT_AUTHOR_EMAIL", "t@t")
            .env("GIT_COMMITTER_NAME", "t")
            .env("GIT_COMMITTER_EMAIL", "t@t")
            .env("GIT_ALLOW_PROTOCOL", "file")
            .output()
            .unwrap();
        assert!(
            out.status.success(),
            "git {args:?}: {}",
            String::from_utf8_lossy(&out.stderr)
        );
        String::from_utf8_lossy(&out.stdout).trim().to_string()
    }

    fn commit(&self, dir: &Path, file: &str) {
        fs::write(dir.join(file), file).unwrap();
        self.git(dir, &["add", file]);
        self.git(dir, &["commit", "-qm", file]);
    }

    /// A bare remote with one commit on main, and a clone of it in work/.
    fn clone(&self, name: &str) -> (PathBuf, PathBuf) {
        let remote = self.path(&format!("remotes/{name}.git"));
        self.git(
            self.home.path(),
            &[
                "init",
                "-q",
                "--bare",
                "-b",
                "main",
                remote.to_str().unwrap(),
            ],
        );
        let seed = self.path(&format!("seed_{name}"));
        self.git(
            self.home.path(),
            &[
                "clone",
                "-q",
                remote.to_str().unwrap(),
                seed.to_str().unwrap(),
            ],
        );
        self.git(&seed, &["checkout", "-qb", "main"]);
        self.commit(&seed, "one");
        self.git(&seed, &["push", "-q", "origin", "main"]);
        let clone = self.work().join(name);
        self.git(
            self.home.path(),
            &[
                "clone",
                "-q",
                remote.to_str().unwrap(),
                clone.to_str().unwrap(),
            ],
        );
        (clone, seed)
    }

    fn cmd(&self) -> assert_cmd::Command {
        let mut cmd = cargo_bin_cmd!("sync2");
        cmd.env("HOME", self.home.path())
            .env("GIT_CONFIG_NOSYSTEM", "1")
            .env("GIT_AUTHOR_NAME", "t")
            .env("GIT_AUTHOR_EMAIL", "t@t")
            .env("GIT_COMMITTER_NAME", "t")
            .env("GIT_COMMITTER_EMAIL", "t@t")
            .env("GIT_ALLOW_PROTOCOL", "file")
            .env_remove("NO_COLOR")
            .args(["-y", "-d"])
            .arg(self.work());
        cmd
    }

    /// Run a sync; return (exit code, stdout).
    fn sync(&self) -> (i32, String) {
        let out = self.cmd().output().unwrap();
        (
            out.status.code().unwrap(),
            String::from_utf8_lossy(&out.stdout).into_owned(),
        )
    }
}

fn row<'a>(stdout: &'a str, name: &str) -> &'a str {
    stdout
        .lines()
        .find(|l| l.contains(&format!("/work/{name} ")))
        .unwrap_or_else(|| panic!("no row for {name} in:\n{stdout}"))
}

#[test]
fn up_to_date() {
    let f = Fixture::new();
    f.clone("a");
    let (code, out) = f.sync();
    assert!(row(&out, "a").contains("[ OK ]"), "{out}");
    assert!(row(&out, "a").contains("clean  Already up to date"));
    assert_eq!(code, 0);
}

#[test]
fn ahead_pushes() {
    let f = Fixture::new();
    let (clone, _) = f.clone("a");
    f.commit(&clone, "two");
    let (code, out) = f.sync();
    assert!(
        row(&out, "a").contains("[PUSH]") && row(&out, "a").contains("Pushed 1 local commit(s)"),
        "{out}"
    );
    assert_eq!(code, 0);
    assert_eq!(
        f.git(&clone, &["rev-parse", "HEAD"]),
        f.git(&clone, &["rev-parse", "origin/main"])
    );
}

#[test]
fn behind_fast_forwards() {
    let f = Fixture::new();
    let (clone, seed) = f.clone("a");
    f.commit(&seed, "two");
    f.commit(&seed, "three");
    f.git(&seed, &["push", "-q", "origin", "main"]);
    let (code, out) = f.sync();
    assert!(
        row(&out, "a").contains("[SYNC]")
            && row(&out, "a").contains("Fast-forwarded by 2 remote commit(s)"),
        "{out}"
    );
    assert_eq!(code, 0);
    assert!(clone.join("three").exists());
}

#[test]
fn diverged_needs_attention() {
    let f = Fixture::new();
    let (clone, seed) = f.clone("a");
    f.commit(&seed, "two");
    f.git(&seed, &["push", "-q", "origin", "main"]);
    f.commit(&clone, "local");
    let (code, out) = f.sync();
    assert!(
        row(&out, "a").contains("[WARN]")
            && row(&out, "a").contains("Diverged (ahead 1, behind 1)"),
        "{out}"
    );
    assert_eq!(code, 2);
}

#[test]
fn dirty_needs_attention() {
    let f = Fixture::new();
    let (clone, _) = f.clone("a");
    fs::write(clone.join("one"), "changed").unwrap();
    fs::write(clone.join("new"), "untracked").unwrap();
    let (code, out) = f.sync();
    assert!(
        row(&out, "a").contains("dirty  Uncommitted changes (2 file(s))"),
        "{out}"
    );
    assert_eq!(code, 2);
}

#[test]
fn no_upstream_clean_is_ok_dirty_needs_attention() {
    let f = Fixture::new();
    let clean = f.work().join("clean");
    let dirty = f.work().join("dirty");
    for repo in [&clean, &dirty] {
        f.git(
            f.home.path(),
            &["init", "-q", "-b", "main", repo.to_str().unwrap()],
        );
        f.commit(repo, "one");
    }
    fs::write(dirty.join("x"), "x").unwrap();
    let (code, out) = f.sync();
    assert!(
        row(&out, "clean").contains("[ OK ]")
            && row(&out, "clean").contains("No upstream branch configured"),
        "{out}"
    );
    assert!(
        row(&out, "dirty")
            .contains("No upstream branch configured, uncommitted changes (1 file(s))"),
        "{out}"
    );
    assert_eq!(code, 2);
}

#[test]
fn upstream_gone_is_ok_when_clean() {
    let f = Fixture::new();
    let (clone, _) = f.clone("a");
    f.git(&clone, &["checkout", "-qb", "feature"]);
    f.git(&clone, &["push", "-qu", "origin", "feature"]);
    f.git(&clone, &["push", "-q", "origin", "--delete", "feature"]);
    f.git(&clone, &["config", "fetch.prune", "true"]);
    let (code, out) = f.sync();
    assert!(
        row(&out, "a").contains("Upstream branch does not exist on remote"),
        "{out}"
    );
    assert_eq!(code, 0);
}

#[test]
fn detached_head_needs_attention() {
    let f = Fixture::new();
    let (clone, _) = f.clone("a");
    f.git(&clone, &["checkout", "-q", "--detach"]);
    let (code, out) = f.sync();
    assert!(
        row(&out, "a").contains("Detached HEAD or no branch"),
        "{out}"
    );
    assert_eq!(code, 2);
}

#[test]
fn fetch_failure_fails() {
    let f = Fixture::new();
    let (clone, _) = f.clone("a");
    f.git(
        &clone,
        &["remote", "set-url", "origin", "/nonexistent/repo.git"],
    );
    let (code, out) = f.sync();
    assert!(
        row(&out, "a").contains("[FAIL]")
            && row(&out, "a")
                .contains("Fetch failed - configured upstream remote is missing or unreachable"),
        "{out}"
    );
    assert_eq!(code, 1);
}

#[test]
fn local_upstream_needs_attention() {
    let f = Fixture::new();
    let (clone, _) = f.clone("a");
    f.git(&clone, &["config", "branch.main.remote", "."]);
    let (_, out) = f.sync();
    assert!(
        row(&out, "a").contains("Local upstream remotes are not supported"),
        "{out}"
    );
}

#[test]
fn submodule_is_skipped_and_updated_after_fast_forward() {
    let f = Fixture::new();
    let (_, lib_seed) = f.clone("lib");
    let (clone, seed) = f.clone("app");
    let lib_remote = f.path("remotes/lib.git");
    f.git(
        &seed,
        &[
            "-c",
            "protocol.file.allow=always",
            "submodule",
            "add",
            "-q",
            lib_remote.to_str().unwrap(),
            "lib",
        ],
    );
    f.git(&seed, &["commit", "-qm", "add lib"]);
    f.git(&seed, &["push", "-q", "origin", "main"]);
    f.git(&clone, &["pull", "-q"]);
    f.git(
        &clone,
        &[
            "-c",
            "protocol.file.allow=always",
            "submodule",
            "update",
            "-q",
            "--init",
        ],
    );
    // Move the gitlink upstream.
    f.commit(&lib_seed, "two");
    f.git(&lib_seed, &["push", "-q", "origin", "main"]);
    f.git(&seed.join("lib"), &["pull", "-q", "origin", "main"]);
    f.git(&seed, &["commit", "-qam", "bump lib"]);
    f.git(&seed, &["push", "-q", "origin", "main"]);

    f.git(&clone, &["config", "protocol.file.allow", "always"]);
    let (_, out) = f.sync();
    assert!(
        !out.contains("/work/app/lib "),
        "submodule should be skipped:\n{out}"
    );
    assert!(row(&out, "app").contains("Fast-forwarded by 1"), "{out}");
    assert!(
        clone.join("lib/two").exists(),
        "submodule not checked out after fast-forward"
    );
    assert_eq!(f.git(&clone, &["status", "--porcelain"]), "");
}

#[test]
fn ignore_patterns_skip_repos() {
    let f = Fixture::new();
    f.clone("keep");
    f.clone("skip_plain");
    f.clone("skip_glob");
    fs::create_dir_all(f.path("dot_local")).unwrap();
    fs::write(
        f.path("dot_local/list_of_ignores.txt"),
        format!("# c\n{}\n", f.work().join("skip_plain").display()),
    )
    .unwrap();
    let out = f.cmd().args(["-i", "*/skip_glob"]).output().unwrap();
    let out = String::from_utf8_lossy(&out.stdout);
    assert!(out.contains("/work/keep "));
    assert!(
        !out.contains("skip_plain") && !out.contains("skip_glob"),
        "{out}"
    );
}

#[test]
fn list_mode_prints_only_attention_on_stdout() {
    let f = Fixture::new();
    f.clone("fine");
    let (clone, _) = f.clone("messy");
    fs::write(clone.join("x"), "x").unwrap();
    let out = f.cmd().arg("list").output().unwrap();
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert_eq!(stdout.lines().count(), 1, "{stdout}");
    assert!(
        stdout.contains("/work/messy  Uncommitted changes (1 file(s))"),
        "{stdout}"
    );
    assert!(String::from_utf8_lossy(&out.stderr).contains("item(s) processed"));
    assert_eq!(out.status.code(), Some(2));
}

#[test]
fn ignore_subcommand_writes_both_lists_once() {
    let f = Fixture::new();
    let (clone, _) = f.clone("a");
    let config = f.path("dot_local/sync2.toml");
    fs::create_dir_all(f.path("dot_local")).unwrap();
    fs::write(&config, "# keep me\njobs = 4\n").unwrap();
    for _ in 0..2 {
        f.cmd().args(["ignore"]).arg(&clone).assert().success();
    }
    let txt = fs::read_to_string(f.path("dot_local/list_of_ignores.txt")).unwrap();
    let toml = fs::read_to_string(&config).unwrap();
    let canonical = fs::canonicalize(&clone).unwrap();
    assert_eq!(txt.matches(canonical.to_str().unwrap()).count(), 1, "{txt}");
    assert_eq!(
        toml.matches(canonical.to_str().unwrap()).count(),
        1,
        "{toml}"
    );
    assert!(
        toml.contains("# keep me") && toml.contains("jobs = 4"),
        "{toml}"
    );
    let (_, out) = f.sync();
    assert!(!out.contains("/work/a "), "{out}");
}

#[test]
fn plain_output_off_a_tty_has_no_escape_codes() {
    let f = Fixture::new();
    f.clone("a");
    let (_, out) = f.sync();
    assert!(!out.contains('\x1b'), "{out:?}");
    assert!(out.contains("Synced (1)"), "{out}");
}
