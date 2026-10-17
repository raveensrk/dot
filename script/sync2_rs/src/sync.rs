//! Inspect and sync one repo. Pure worker: no printing, no lazygit.

use std::path::{Path, PathBuf};

use crate::git;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Status {
    Ok,
    Pushed,
    Synced,
    Attention,
    Failed,
    /// Not a repo, or a submodule: never reported.
    Skip,
}

impl Status {
    pub fn is_synced(self) -> bool {
        matches!(self, Status::Ok | Status::Pushed | Status::Synced)
    }
}

#[derive(Clone)]
pub struct Outcome {
    pub repo: PathBuf,
    pub status: Status,
    pub message: String,
    /// None when the working tree was never inspected.
    pub dirty: Option<bool>,
}

pub struct Options {
    /// Fetch only the upstream remote (as `,sync.py` does) instead of all.
    pub fetch_upstream_only: bool,
}

pub fn sync_repo(path: &Path, opts: &Options, step: &dyn Fn(&str)) -> Outcome {
    let out = |status, message: String, dirty| Outcome {
        repo: path.to_path_buf(),
        status,
        message,
        dirty,
    };

    step("inspecting");
    let repo = match git::open(path) {
        git::Open::NotRepo => return out(Status::Skip, "Not a git repository".into(), None),
        git::Open::Submodule => {
            return out(Status::Skip, "Submodule of another repository".into(), None);
        }
        git::Open::Repo(repo) => repo,
    };

    // Inspect the working tree up front so every real repo is reported as
    // clean or dirty, even when it later fails on branch, upstream or fetch.
    let dirty_count = match git::dirty_count(&repo) {
        Ok(n) => n,
        Err(e) => return out(Status::Failed, format!("Status check failed - {e}"), None),
    };
    let dirty = dirty_count > 0;
    let d = Some(dirty);

    let branch = match git::branch(&repo) {
        Ok(Some(branch)) => branch,
        Ok(None) => return out(Status::Attention, "Detached HEAD or no branch".into(), d),
        Err(e) => return out(Status::Failed, format!("Branch check failed - {e}"), d),
    };

    let remote = git::config_string(&repo, &format!("branch.{}.remote", branch.name));
    let merge_ref = git::config_string(&repo, &format!("branch.{}.merge", branch.name));
    let (Some(remote), Some(merge_ref)) = (remote, merge_ref) else {
        // Nothing to sync against. A clean tree has nothing to lose.
        if !dirty {
            return out(Status::Ok, "No upstream branch configured".into(), d);
        }
        return out(
            Status::Attention,
            format!("No upstream branch configured, uncommitted changes ({dirty_count} file(s))"),
            d,
        );
    };
    if remote == "." {
        return out(
            Status::Attention,
            "Local upstream remotes are not supported".into(),
            d,
        );
    }

    step("fetching");
    let fetch = if opts.fetch_upstream_only {
        git::run(path, &["fetch", &remote])
    } else {
        git::run(path, &["fetch", "--all"])
    };
    if !fetch.ok {
        return out(
            Status::Failed,
            format!("Fetch failed - {}", git::fetch_reason(&fetch.stderr)),
            d,
        );
    }

    // Re-open: the fetch moved refs under the handle we hold.
    let repo = match git::open(path) {
        git::Open::Repo(repo) => repo,
        _ => return out(Status::Failed, "Repository vanished after fetch".into(), d),
    };
    let Some((upstream, upstream_id)) = git::upstream(&repo, &branch) else {
        // Configured upstream, but no remote-tracking ref even after a
        // successful fetch: the remote is empty or the branch was deleted.
        if !dirty {
            return out(
                Status::Ok,
                "Upstream branch does not exist on remote".into(),
                d,
            );
        }
        return out(
            Status::Attention,
            format!(
                "Upstream branch does not exist on remote, uncommitted changes ({dirty_count} file(s))"
            ),
            d,
        );
    };

    if dirty {
        return out(
            Status::Attention,
            format!("Uncommitted changes ({dirty_count} file(s))"),
            d,
        );
    }

    let (ahead, behind) = match git::ahead_behind(&repo, upstream_id) {
        Ok(counts) => counts,
        Err(e) => {
            return out(
                Status::Failed,
                format!("Upstream comparison failed - {e}"),
                d,
            );
        }
    };

    if ahead > 0 && behind > 0 {
        return out(
            Status::Attention,
            format!("Diverged (ahead {ahead}, behind {behind})"),
            d,
        );
    }

    if ahead > 0 {
        step(&format!("pushing {ahead} commit(s)"));
        let push = git::run(path, &["push", &remote, &format!("HEAD:{merge_ref}")]);
        if push.ok {
            return out(Status::Pushed, format!("Pushed {ahead} local commit(s)"), d);
        }
        let reason = if push.stderr.is_empty() {
            "see git output".into()
        } else {
            push.stderr
        };
        return out(Status::Failed, format!("Push failed - {reason}"), d);
    }

    if behind == 0 {
        return out(Status::Ok, "Already up to date".into(), d);
    }

    step(&format!("fast-forwarding {behind} commit(s)"));
    let merge = git::run(path, &["merge", "--ff-only", &upstream]);
    if !merge.ok {
        let reason = if merge.stderr.is_empty() {
            "upstream changed".into()
        } else {
            merge.stderr
        };
        return out(
            Status::Attention,
            format!("Fast-forward failed - {reason}"),
            d,
        );
    }

    // `git merge` takes no --recurse-submodules and submodule.recurse does not
    // cover merge, so a gitlink the merge moved is not checked out yet. No
    // --init: submodules the user never initialised stay that way.
    step("updating submodules");
    let update = git::run(path, &["submodule", "update", "--recursive"]);
    if !update.ok {
        let reason = if update.stderr.is_empty() {
            "unknown error".into()
        } else {
            update.stderr
        };
        return out(
            Status::Attention,
            format!(
                "Fast-forwarded by {behind} remote commit(s), submodule update failed - {reason}"
            ),
            d,
        );
    }
    out(
        Status::Synced,
        format!("Fast-forwarded by {behind} remote commit(s)"),
        d,
    )
}
