//! Collect candidate repo paths from list files and directory scans.

use std::fs;
use std::path::{Path, PathBuf};

use crate::config::{expand_ignore, expand_path};
use crate::ignore::Ignores;

/// What collection found, plus problems to report as failures.
#[derive(Default)]
pub struct Collected {
    pub repos: Vec<PathBuf>,
    pub errors: Vec<(String, String)>,
}

/// Read list files (repo paths, `dir:` and `ignore:` lines), then scan dirs.
/// `ignore:` lines are appended to `ignores`.
pub fn collect(list_files: &[PathBuf], dirs: &[PathBuf], ignores: &mut Vec<String>) -> Collected {
    let mut out = Collected::default();
    let mut dirs: Vec<PathBuf> = dirs.to_vec();
    for list in list_files {
        let text = match fs::read_to_string(list) {
            Ok(text) => text,
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
                out.errors
                    .push((list.display().to_string(), "List file not found".into()));
                continue;
            }
            Err(e) => {
                out.errors.push((
                    list.display().to_string(),
                    format!("Could not read list file - {e}"),
                ));
                continue;
            }
        };
        let base = list.parent();
        for line in text.lines().map(str::trim) {
            if line.is_empty() || line.starts_with('#') {
                continue;
            }
            if let Some(rest) = line.strip_prefix("dir:") {
                dirs.push(expand_path(rest.trim(), base));
            } else if let Some(rest) = line.strip_prefix("ignore:") {
                ignores.push(expand_ignore(rest.trim(), base));
            } else {
                out.repos.push(expand_path(line, base));
            }
        }
    }

    let prune = Ignores::new(ignores.iter().cloned());
    for dir in &dirs {
        if !dir.is_dir() {
            out.errors
                .push((dir.display().to_string(), "Directory not found".into()));
            continue;
        }
        if let Err(e) = scan(dir, &prune, &mut out.repos) {
            out.errors.push((
                dir.display().to_string(),
                format!("Repository scan failed - {e}"),
            ));
        }
    }
    out
}

/// Every directory under `dir` holding a `.git` (directory or file).
/// Symlinked directories are not followed; ignored plain paths are pruned.
fn scan(dir: &Path, prune: &Ignores, repos: &mut Vec<PathBuf>) -> std::io::Result<()> {
    let mut stack = vec![dir.to_path_buf()];
    while let Some(current) = stack.pop() {
        let entries = match fs::read_dir(&current) {
            Ok(entries) => entries,
            // The top dir must be readable; unreadable subdirs are skipped.
            Err(e) if current == dir => return Err(e),
            Err(_) => continue,
        };
        for entry in entries.flatten() {
            let name = entry.file_name();
            let Ok(kind) = entry.file_type() else {
                continue;
            };
            if name == ".git" {
                repos.push(current.clone());
                continue;
            }
            if kind.is_dir() {
                let path = entry.path();
                if !prune.matches_prefix(&path.to_string_lossy()) {
                    stack.push(path);
                }
            }
        }
    }
    Ok(())
}

/// Resolve symlinks, sort, drop duplicates.
pub fn dedup(repos: Vec<PathBuf>) -> Vec<PathBuf> {
    let mut resolved: Vec<PathBuf> = repos
        .into_iter()
        .map(|r| fs::canonicalize(&r).unwrap_or(r))
        .collect();
    resolved.sort();
    resolved.dedup();
    resolved
}
