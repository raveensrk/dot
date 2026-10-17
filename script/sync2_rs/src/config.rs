//! Where repos come from and which ones to skip: `sync2.toml`, the two txt
//! lists shared with `,sync.py`, and the command line.

use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use serde::Deserialize;

/// `~/dot_local/sync2.toml`. Every key is optional.
#[derive(Default, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct Config {
    pub jobs: Option<usize>,
    pub repos: Vec<String>,
    pub dirs: Vec<String>,
    pub ignore: Vec<String>,
    /// TUI theme: "ayu" (default) or "gruvbox".
    pub theme: Option<String>,
}

pub fn home() -> PathBuf {
    std::env::var_os("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("/"))
}

pub fn default_config() -> PathBuf {
    home().join("dot_local/sync2.toml")
}

pub fn repo_list() -> PathBuf {
    home().join("dot_local/list_of_repos.txt")
}

pub fn ignore_list() -> PathBuf {
    home().join("dot_local/list_of_ignores.txt")
}

pub fn default_dir() -> PathBuf {
    home().join("repos")
}

/// A missing file is an empty config, not an error.
pub fn load(path: &Path) -> Result<Config> {
    match fs::read_to_string(path) {
        Ok(text) => {
            toml::from_str(&text).with_context(|| format!("{}: invalid config", path.display()))
        }
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(Config::default()),
        Err(e) => Err(e).with_context(|| format!("{}: could not read config", path.display())),
    }
}

/// Expand `~` and `$VARS`; resolve a relative path against `base`.
pub fn expand_path(value: &str, base: Option<&Path>) -> PathBuf {
    let expanded = shellexpand::full(value)
        .map(|s| s.into_owned())
        .unwrap_or_else(|_| value.to_string());
    let path = PathBuf::from(expanded);
    match base {
        Some(base) if path.is_relative() => base.join(path),
        _ => path,
    }
}

pub fn is_glob(value: &str) -> bool {
    value.contains(['*', '?', '['])
}

/// Globs are kept as written (after ~ and $VAR); plain paths are made absolute.
pub fn expand_ignore(value: &str, base: Option<&Path>) -> String {
    let expanded = shellexpand::full(value)
        .map(|s| s.into_owned())
        .unwrap_or_else(|_| value.to_string());
    if is_glob(&expanded) {
        return expanded;
    }
    // Resolve symlinks like repo paths are, so the two compare equal.
    let path = expand_path(&expanded, base);
    fs::canonicalize(&path)
        .unwrap_or(path)
        .to_string_lossy()
        .into_owned()
}

/// Ignore patterns from a one-per-line file. Missing file -> empty.
pub fn read_ignore_file(path: &Path) -> Result<Vec<String>> {
    let text = match fs::read_to_string(path) {
        Ok(text) => text,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(Vec::new()),
        Err(e) => {
            return Err(e)
                .with_context(|| format!("could not read ignore file {}", path.display()));
        }
    };
    Ok(text
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty() && !line.starts_with('#'))
        .map(|line| expand_ignore(line, path.parent()))
        .collect())
}

/// Append `repo` to the txt ignore list unless an entry already covers it.
pub fn append_ignore_txt(path: &Path, repo: &str) -> Result<()> {
    let ignores = crate::ignore::Ignores::new(read_ignore_file(path)?);
    if ignores.matches(repo) {
        return Ok(());
    }
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    // Don't glue the new entry onto an unterminated last line.
    let existing = fs::read_to_string(path).unwrap_or_default();
    let prefix = if !existing.is_empty() && !existing.ends_with('\n') {
        "\n"
    } else {
        ""
    };
    let mut file = fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)?;
    writeln!(file, "{prefix}{repo}")?;
    Ok(())
}

/// Add `repo` to the `ignore` array in the TOML config, keeping comments and order.
pub fn append_ignore_toml(path: &Path, repo: &str) -> Result<()> {
    let text = fs::read_to_string(path).unwrap_or_default();
    let mut doc: toml_edit::DocumentMut = text
        .parse()
        .with_context(|| format!("{}: invalid config", path.display()))?;
    let existing: Vec<String> = doc
        .get("ignore")
        .and_then(|item| item.as_array())
        .map(|array| {
            array
                .iter()
                .filter_map(|v| v.as_str())
                .map(|v| expand_ignore(v, path.parent()))
                .collect()
        })
        .unwrap_or_default();
    if crate::ignore::Ignores::new(existing).matches(repo) {
        return Ok(());
    }
    if doc.get("ignore").and_then(|item| item.as_array()).is_none() {
        doc["ignore"] = toml_edit::value(toml_edit::Array::new());
    }
    doc["ignore"]
        .as_array_mut()
        .expect("ignore is an array")
        .push(repo);
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, doc.to_string())?;
    Ok(())
}

/// Set `theme = "<name>"` in the TOML config, keeping comments and order.
pub fn set_theme(path: &Path, name: &str) -> Result<()> {
    let text = fs::read_to_string(path).unwrap_or_default();
    let mut doc: toml_edit::DocumentMut = text
        .parse()
        .with_context(|| format!("{}: invalid config", path.display()))?;
    doc["theme"] = toml_edit::value(name);
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, doc.to_string())?;
    Ok(())
}
