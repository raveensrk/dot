//! Report rows and the summary, printed after the TUI closes.
//!
//! A row is `[TAG]  <path>  <state>  <message>`: paths are '~'-shortened and
//! padded to the longest path of the run, state is clean, dirty or '-'.

use std::io::Write;
use std::path::Path;

use crate::sync::{Outcome, Status};
use crate::theme::{Role, Theme};

pub const STATE_WIDTH: usize = 5;

pub fn short(path: &Path) -> String {
    let path = path.to_string_lossy();
    let home = crate::config::home();
    let home = home.to_string_lossy();
    if path == home {
        return "~".into();
    }
    match path.strip_prefix(&format!("{home}/")) {
        Some(rest) => format!("~/{rest}"),
        None => path.into_owned(),
    }
}

pub fn column_width<'a>(paths: impl IntoIterator<Item = &'a Path>) -> usize {
    paths
        .into_iter()
        .map(|p| short(p).chars().count())
        .max()
        .unwrap_or(0)
}

pub fn state(dirty: Option<bool>) -> &'static str {
    match dirty {
        None => "-",
        Some(true) => "dirty",
        Some(false) => "clean",
    }
}

pub fn tag(status: Status) -> (&'static str, Role) {
    match status {
        Status::Ok => (" OK ", Role::Ok),
        Status::Pushed => ("PUSH", Role::Push),
        Status::Synced => ("SYNC", Role::Push),
        Status::Attention => ("WARN", Role::Warn),
        Status::Failed | Status::Skip => ("FAIL", Role::Fail),
    }
}

/// One row. `state` of None drops the state column.
pub fn row(
    theme: &Theme,
    tag: &str,
    role: Role,
    subject: &str,
    width: usize,
    state: Option<&str>,
    message: &str,
) -> String {
    let mut cols = vec![
        theme.paint(role, &format!("[{tag}]")),
        theme.paint(Role::Dim, &format!("{subject:<width$}")),
    ];
    if let Some(state) = state {
        cols.push(format!("{state:<STATE_WIDTH$}"));
    }
    cols.push(message.to_string());
    cols.join("  ").trim_end().to_string()
}

pub fn outcome_row(theme: &Theme, o: &Outcome, width: usize) -> String {
    let (t, role) = tag(o.status);
    row(
        theme,
        t,
        role,
        &short(&o.repo),
        width,
        Some(state(o.dirty)),
        &o.message,
    )
}

#[derive(Default, Clone, Copy)]
pub struct Counts {
    pub ok: usize,
    pub pushed: usize,
    pub synced: usize,
    pub attention: usize,
    pub failed: usize,
}

impl Counts {
    pub fn add(&mut self, status: Status) {
        match status {
            Status::Ok => self.ok += 1,
            Status::Pushed => self.pushed += 1,
            Status::Synced => self.synced += 1,
            Status::Attention => self.attention += 1,
            Status::Failed => self.failed += 1,
            Status::Skip => {}
        }
    }

    pub fn total(&self) -> usize {
        self.ok + self.pushed + self.synced + self.attention + self.failed
    }
}

fn summary_line(
    theme: &Theme,
    shown: &Counts,
    real: &Counts,
    dirty: Option<usize>,
    dirty_shown: Option<usize>,
) -> String {
    let n = |v: usize| theme.paint(Role::Count, &v.to_string());
    let mut parts = vec![
        format!("{} up-to-date", n(shown.ok)),
        format!("{} pushed", n(shown.pushed)),
        format!("{} synced", n(shown.synced)),
        format!("{} need attention", n(shown.attention)),
        format!("{} failed", n(shown.failed)),
    ];
    if let (Some(_), Some(d)) = (dirty, dirty_shown) {
        parts.push(format!("{} dirty", n(d)));
    }
    let (tag, role) = if real.failed > 0 {
        ("FAIL", Role::Fail)
    } else if real.attention > 0 {
        ("WARN", Role::Warn)
    } else {
        (" OK ", Role::Ok)
    };
    row(
        theme,
        tag,
        role,
        &format!("{} item(s) processed", shown.total()),
        0,
        None,
        &parts.join(", "),
    )
}

/// Print the summary line.
pub fn summary(theme: &Theme, out: &mut dyn Write, counts: &Counts, dirty: Option<usize>) {
    let _ = writeln!(out, "{}", summary_line(theme, counts, counts, dirty, dirty));
}

/// A report section: a bold heading with its count, then its rows.
pub fn section(
    out: &mut dyn Write,
    theme: &Theme,
    title: &str,
    rows: &[&Outcome],
    width: usize,
) -> std::io::Result<()> {
    if rows.is_empty() {
        return Ok(());
    }
    writeln!(
        out,
        "\n{} {}",
        theme.bold(title),
        theme.paint(Role::Count, &format!("({})", rows.len()))
    )?;
    for o in rows {
        writeln!(out, "{}", outcome_row(theme, o, width))?;
    }
    Ok(())
}
