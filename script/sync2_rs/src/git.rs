//! Git access. Reads go through gix in-process; fetch, push, merge and
//! submodule update spawn `git`, so SSH, credential helpers and hooks work.

use std::io::Read;
use std::path::Path;
use std::process::{Command, Stdio};
use std::thread;
use std::time::{Duration, Instant};

pub const TIMEOUT: Duration = Duration::from_secs(60);

pub struct Output {
    pub ok: bool,
    pub stderr: String,
}

/// `git -C repo args...`, noninteractive, killed after TIMEOUT.
pub fn run(repo: &Path, args: &[&str]) -> Output {
    let child = Command::new("git")
        .arg("-C")
        .arg(repo)
        .args(args)
        .env("GIT_TERMINAL_PROMPT", "0")
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn();
    let mut child = match child {
        Ok(child) => child,
        Err(e) => {
            return Output {
                ok: false,
                stderr: e.to_string(),
            };
        }
    };
    // Drain both pipes on their own threads so a chatty command can't block.
    let drain = |pipe: Option<Box<dyn Read + Send>>| {
        thread::spawn(move || {
            let mut text = String::new();
            if let Some(mut pipe) = pipe {
                let _ = pipe.read_to_string(&mut text);
            }
            text.trim().to_string()
        })
    };
    let out = drain(
        child
            .stdout
            .take()
            .map(|p| Box::new(p) as Box<dyn Read + Send>),
    );
    let err = drain(
        child
            .stderr
            .take()
            .map(|p| Box::new(p) as Box<dyn Read + Send>),
    );

    let start = Instant::now();
    let status = loop {
        match child.try_wait() {
            Ok(Some(status)) => break Some(status),
            Ok(None) if start.elapsed() >= TIMEOUT => {
                let _ = child.kill();
                let _ = child.wait();
                break None;
            }
            Ok(None) => thread::sleep(Duration::from_millis(10)),
            Err(_) => break None,
        }
    };
    let _ = out.join();
    let stderr = err.join().unwrap_or_default();
    match status {
        Some(status) => Output {
            ok: status.success(),
            stderr,
        },
        None => Output {
            ok: false,
            stderr: format!("Git command timed out after {} seconds", TIMEOUT.as_secs()),
        },
    }
}

/// Turn raw `git fetch` stderr into a short reason.
pub fn fetch_reason(stderr: &str) -> String {
    let low = stderr.to_lowercase();
    if low.contains("does not appear to be a git repository")
        || low.contains("could not read from remote")
    {
        return "configured upstream remote is missing or unreachable".into();
    }
    if low.contains("could not resolve host") || low.contains("network is unreachable") {
        return "network unreachable".into();
    }
    if low.contains("permission denied") || low.contains("access rights") {
        return "authentication/permission denied".into();
    }
    stderr
        .lines()
        .map(str::trim)
        .find(|l| !l.is_empty())
        .map(str::to_string)
        .unwrap_or_else(|| "unknown error".into())
}

/// What the reads found about one repo.
pub enum Open {
    /// Not a work tree (no repo, or bare).
    NotRepo,
    /// A submodule: pinned at a detached HEAD by its superproject.
    Submodule,
    Repo(Box<gix::Repository>),
}

pub fn open(path: &Path) -> Open {
    let Ok(repo) = gix::discover(path) else {
        return Open::NotRepo;
    };
    if repo.workdir().is_none() {
        return Open::NotRepo;
    }
    if matches!(repo.kind(), gix::repository::Kind::Submodule) || is_old_form_submodule(&repo) {
        return Open::Submodule;
    }
    Open::Repo(Box::new(repo))
}

/// An old-form submodule keeps its own `.git` directory, so gix reports it as
/// an ordinary repo. Its superproject's index records it as a gitlink.
fn is_old_form_submodule(repo: &gix::Repository) -> bool {
    let Some(workdir) = repo.workdir() else {
        return false;
    };
    let Some(parent) = workdir.parent() else {
        return false;
    };
    let Ok(outer) = gix::discover(parent) else {
        return false;
    };
    let Some(outer_root) = outer.workdir() else {
        return false;
    };
    let Ok(rel) = workdir.strip_prefix(outer_root) else {
        return false;
    };
    let Ok(index) = outer.index_or_empty() else {
        return false;
    };
    let Ok(rel) = gix::path::into_bstr(rel) else {
        return false;
    };
    let rel = gix::path::to_unix_separators_on_windows(rel);
    index
        .entry_by_path(rel.as_ref())
        .is_some_and(|e| e.mode == gix::index::entry::Mode::COMMIT)
}

/// Number of changed paths, as `git status --porcelain` would list them
/// (untracked included, untracked directories collapsed).
pub fn dirty_count(repo: &gix::Repository) -> Result<usize, String> {
    let iter = status(repo, gix::status::UntrackedFiles::Collapsed, None)?;
    let mut count = 0;
    for item in iter {
        let item = item.map_err(|e| e.to_string())?;
        // gix collapses a directory holding only empty directories and
        // ignored files into one untracked entry; git lists nothing for it.
        // Count such a directory only if it holds an untracked file.
        if let gix::status::Item::IndexWorktree(
            gix::status::index_worktree::Item::DirectoryContents { entry, .. },
        ) = &item
            && entry.disk_kind == Some(gix::dir::entry::Kind::Directory)
        {
            let spec: gix::bstr::BString = format!("{}/", entry.rela_path).into();
            let mut files = status(repo, gix::status::UntrackedFiles::Files, Some(spec))?;
            if files.next().is_none() {
                continue;
            }
        }
        count += 1;
    }
    Ok(count)
}

fn status(
    repo: &gix::Repository,
    untracked: gix::status::UntrackedFiles,
    pathspec: Option<gix::bstr::BString>,
) -> Result<gix::status::Iter, String> {
    repo.status(gix::progress::Discard)
        .map_err(|e| e.to_string())?
        .untracked_files(untracked)
        .into_iter(pathspec)
        .map_err(|e| e.to_string())
}

pub struct Branch {
    /// Short branch name, e.g. `main`.
    pub name: String,
    /// `refs/heads/main`.
    pub full: gix::refs::FullName,
}

/// The checked-out branch, or None on a detached HEAD.
pub fn branch(repo: &gix::Repository) -> Result<Option<Branch>, String> {
    let name = repo.head_name().map_err(|e| e.to_string())?;
    Ok(name.map(|full| Branch {
        name: full.shorten().to_string(),
        full,
    }))
}

pub fn config_string(repo: &gix::Repository, key: &str) -> Option<String> {
    repo.config_snapshot()
        .string(key)
        .map(|v| v.to_string())
        .filter(|v| !v.is_empty())
}

/// The remote-tracking ref for the branch's upstream, if it exists locally.
pub fn upstream(repo: &gix::Repository, branch: &Branch) -> Option<(String, gix::ObjectId)> {
    let name = repo
        .branch_remote_tracking_ref_name(branch.full.as_ref(), gix::remote::Direction::Fetch)?
        .ok()?;
    let mut reference = repo.find_reference(name.as_ref()).ok()?;
    let id = reference.peel_to_id().ok()?.detach();
    Some((name.as_bstr().to_string(), id))
}

/// (ahead, behind) of HEAD against `upstream`.
pub fn ahead_behind(
    repo: &gix::Repository,
    upstream: gix::ObjectId,
) -> Result<(usize, usize), String> {
    let head = repo.head_id().map_err(|e| e.to_string())?.detach();
    let count = |tip: gix::ObjectId, hidden: gix::ObjectId| -> Result<usize, String> {
        let walk = repo
            .rev_walk([tip])
            .with_hidden([hidden])
            .all()
            .map_err(|e| e.to_string())?;
        let mut n = 0;
        for info in walk {
            info.map_err(|e| e.to_string())?;
            n += 1;
        }
        Ok(n)
    };
    Ok((count(head, upstream)?, count(upstream, head)?))
}
