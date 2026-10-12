//! Ignore matching: a glob matches shell-style (`*` crosses `/`, like
//! Python's fnmatch); a plain path skips that path and everything beneath it.

use globset::{GlobBuilder, GlobMatcher};

pub struct Ignores {
    globs: Vec<GlobMatcher>,
    prefixes: Vec<String>,
}

impl Ignores {
    pub fn new(patterns: impl IntoIterator<Item = String>) -> Self {
        let mut globs = Vec::new();
        let mut prefixes = Vec::new();
        for pattern in patterns {
            if crate::config::is_glob(&pattern) {
                match GlobBuilder::new(&pattern).literal_separator(false).build() {
                    Ok(glob) => globs.push(glob.compile_matcher()),
                    // An unparsable glob still works as a literal path.
                    Err(_) => prefixes.push(pattern),
                }
            } else {
                let trimmed = pattern.trim_end_matches('/');
                prefixes.push(if trimmed.is_empty() {
                    "/".to_string()
                } else {
                    trimmed.to_string()
                });
            }
        }
        Ignores { globs, prefixes }
    }

    pub fn matches(&self, path: &str) -> bool {
        self.matches_prefix(path) || self.globs.iter().any(|g| g.is_match(path))
    }

    /// Plain-path match only: safe for pruning a directory walk, since
    /// everything beneath a matching directory matches too.
    pub fn matches_prefix(&self, path: &str) -> bool {
        self.prefixes.iter().any(|p| {
            path == p
                || p == "/"
                || (path.starts_with(p.as_str()) && path.as_bytes().get(p.len()) == Some(&b'/'))
        })
    }
}

#[cfg(test)]
mod tests {
    use super::Ignores;

    fn ig(patterns: &[&str]) -> Ignores {
        Ignores::new(patterns.iter().map(|s| s.to_string()))
    }

    #[test]
    fn plain_path_covers_itself_and_below() {
        let i = ig(&["/a/b/"]);
        assert!(i.matches("/a/b"));
        assert!(i.matches("/a/b/c"));
        assert!(!i.matches("/a/bc"));
        assert!(!i.matches("/a"));
    }

    #[test]
    fn glob_star_crosses_slashes() {
        let i = ig(&["*/build/_deps/*"]);
        assert!(i.matches("/home/u/repos/x/build/_deps/fmt-src"));
        assert!(!i.matches("/home/u/repos/x/build"));
    }

    #[test]
    fn glob_question_and_class() {
        let i = ig(&["/r/repo?", "/r/[xy]z"]);
        assert!(i.matches("/r/repo1"));
        assert!(i.matches("/r/yz"));
        assert!(!i.matches("/r/repo12"));
    }
}
