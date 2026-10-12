//! Output rows, the live progress display and the summary.
//!
//! A row is `[TAG]  <path>  <state>  <message>`: paths are '~'-shortened and
//! padded to the longest path of the run, state is clean, dirty or '-'.

use std::io::Write;
use std::path::Path;
use std::sync::Arc;
use std::thread;
use std::time::Duration;

use indicatif::{MultiProgress, ProgressBar, ProgressDrawTarget, ProgressStyle};

use crate::sync::{Outcome, Status};
use crate::theme::{Role, Theme};

pub const STATE_WIDTH: usize = 5;
const COUNT_UP: Duration = Duration::from_millis(400);

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

/// Spinners per worker and an overall bar, cleared when the scan ends; the
/// grouped report prints after. TTY only.
pub struct Live {
    multi: MultiProgress,
    overall: ProgressBar,
    theme: Theme,
}

impl Live {
    pub fn new(theme: Theme, total: usize) -> Arc<Self> {
        let multi = MultiProgress::with_draw_target(ProgressDrawTarget::stdout());
        let style = ProgressStyle::with_template(&format!(
            "{{bar:24.{bar}}}  {{pos:.{count}}}/{{len}}  {{elapsed}}  eta {{eta}}",
            bar = theme.indicatif(Role::Count),
            count = theme.indicatif(Role::Count),
        ))
        .expect("valid template")
        .progress_chars("█▉▊▋▌▍▎▏░");
        let overall = multi.add(ProgressBar::new(total as u64).with_style(style));
        overall.enable_steady_tick(Duration::from_millis(100));
        Arc::new(Live {
            multi,
            overall,
            theme,
        })
    }

    /// A spinner line for one worker.
    pub fn spinner(&self) -> ProgressBar {
        let style = ProgressStyle::with_template(&format!(
            "{{spinner:.{}}} {{msg}}",
            self.theme.indicatif(Role::Spinner)
        ))
        .expect("valid template")
        .tick_chars("⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏ ");
        let bar = self
            .multi
            .insert_before(&self.overall, ProgressBar::new_spinner().with_style(style));
        bar.enable_steady_tick(Duration::from_millis(80));
        bar
    }

    pub fn step(&self, bar: &ProgressBar, repo: &Path, what: &str) {
        bar.set_message(format!(
            "{}  {}",
            self.theme.paint(Role::Dim, &short(repo)),
            what
        ));
    }

    pub fn finish(&self) {
        self.overall.inc(1);
    }

    pub fn close(&self) {
        self.overall.finish_and_clear();
        let _ = self.multi.clear();
    }
}

#[derive(Default, Clone, Copy)]
pub struct Counts {
    pub ok: usize,
    pub pushed: usize,
    pub synced: usize,
    pub manual: usize,
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

    fn total(&self) -> usize {
        self.ok + self.pushed + self.synced + self.manual + self.attention + self.failed
    }

    fn scaled(&self, f: f64) -> Counts {
        let s = |n: usize| (n as f64 * f).round() as usize;
        Counts {
            ok: s(self.ok),
            pushed: s(self.pushed),
            synced: s(self.synced),
            manual: s(self.manual),
            attention: s(self.attention),
            failed: s(self.failed),
        }
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
        format!("{} handled manually", n(shown.manual)),
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

/// Print the summary; on a TTY the numbers count up first.
pub fn summary(
    theme: &Theme,
    out: &mut dyn Write,
    counts: &Counts,
    dirty: Option<usize>,
    animate: bool,
) {
    if animate {
        const FRAMES: u32 = 8;
        // Autowrap off while frames draw: a line wider than the terminal
        // would wrap, and \r only rewinds its last row, leaving each frame
        // behind. Unwrapped, a long frame is cut at the edge instead.
        let _ = write!(out, "\x1b[?7l");
        for frame in 1..FRAMES {
            let f = frame as f64 / FRAMES as f64;
            let shown = counts.scaled(f);
            let d = dirty.map(|d| (d as f64 * f).round() as usize);
            let _ = write!(
                out,
                "\r\x1b[2K{}",
                summary_line(theme, &shown, counts, dirty, d)
            );
            let _ = out.flush();
            thread::sleep(COUNT_UP / FRAMES);
        }
        let _ = write!(out, "\r\x1b[2K\x1b[?7h");
    }
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
