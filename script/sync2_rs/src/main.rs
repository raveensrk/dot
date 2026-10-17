//! `,sync2`: sync many git repositories in parallel, in a TUI. Rust rewrite
//! of `script/legacy/,sync.py`, which stays as the legacy tool.
//!
//! The TUI (src/tui.rs) opens at once and the scan streams into it: repos
//! grouped Needs attention / Failed / Syncing / Synced, a detail pane, keys
//! for lazygit (then re-sync), re-sync, ignore and theme. On quit, or when a
//! clean run closes itself, the report prints to the scrollback. Off a
//! terminal it refuses to run.
//!
//! Report rows: `[TAG]  <path>  <state>  <message>`. Tags: OK, PUSH, SYNC
//! (synced), WARN (needs attention), FAIL. State is clean, dirty or '-'.
//!
//! Per repo: not a repo, submodule or ignored -> skipped silently. Detached
//! HEAD -> attention. No upstream, or upstream gone after fetch -> OK if clean,
//! attention if dirty. Local ('.') upstream -> attention. `git fetch --all`
//! fails -> FAIL. Dirty -> attention. Diverged -> attention. Ahead only ->
//! push HEAD:<merge ref>. Behind only -> `merge --ff-only`, then
//! `submodule update --recursive` (no --init); failure -> attention.
//!
//! Sources: `~/dot_local/sync2.toml` (`jobs`, `repos`, `dirs`, `ignore`,
//! `theme`), `~/dot_local/list_of_repos.txt` (paths, `dir:` and `ignore:`
//! lines) and `~/repos` (or the TOML `dirs`). `-d`/`-f` replace every default
//! source. Ignores from the TOML, `~/dot_local/list_of_ignores.txt`, `ignore:`
//! lines and `-i` always apply. A plain path skips everything beneath it; a
//! glob matches shell-style (`*` crosses '/'). Ignoring in the TUI writes
//! both files.
//!
//! Themes: Ayu Dark (default) and Gruvbox Dark Hard (src/theme.rs). `t` in
//! the TUI cycles and saves `theme` in sync2.toml; `--theme` overrides.
//!
//! Reads use gix in-process; fetch, push, merge and submodule update spawn
//! `git` (GIT_TERMINAL_PROMPT=0, 60 s timeout). Exit: 0 ok, 1 failure,
//! 2 attention needed.

mod config;
mod git;
mod ignore;
mod sources;
mod sync;
mod theme;
mod tui;
mod ui;

use std::collections::VecDeque;
use std::io::{self, IsTerminal, Write};
use std::path::PathBuf;
use std::process::ExitCode;
use std::sync::{Arc, Mutex, mpsc};
use std::thread;

use clap::Parser;

use crate::sync::{Outcome, Status};
use crate::theme::{Name, Role, Theme};
use crate::ui::Counts;

#[derive(Parser)]
#[command(
    name = ",sync2",
    about = "Sync many git repositories in parallel, in a TUI."
)]
struct Cli {
    /// Repositories to sync concurrently (default: config `jobs`, else all at once).
    #[arg(short, long, value_name = "N")]
    jobs: Option<usize>,
    /// Config file (default: ~/dot_local/sync2.toml).
    #[arg(short, long, value_name = "FILE")]
    config: Option<PathBuf>,
    /// Directory to scan for repos (repeatable; replaces default sources).
    #[arg(short, long = "dir", value_name = "DIR")]
    dirs: Vec<String>,
    /// List file of repo paths, 'dir:' and 'ignore:' lines (repeatable; replaces default sources).
    #[arg(short, long = "file", value_name = "FILE")]
    files: Vec<String>,
    /// Path or glob to skip (repeatable).
    #[arg(short, long = "ignore", value_name = "PAT")]
    ignores: Vec<String>,
    /// Theme: ayu or gruvbox (default: config `theme`, else ayu).
    #[arg(short, long, value_name = "NAME")]
    theme: Option<String>,
    /// Sync and print the report without the TUI (for tests).
    #[arg(long, hide = true)]
    headless: bool,
    /// Fetch only the upstream remote, like ,sync.py (for benchmarks).
    #[arg(long, hide = true)]
    fetch_upstream_only: bool,
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    match run(cli) {
        Ok(code) => ExitCode::from(code),
        Err(e) => {
            eprintln!(
                "{}",
                Theme::stderr(Name::Ayu).paint(Role::Fail, &format!("[FAIL]  {e:#}"))
            );
            ExitCode::from(1)
        }
    }
}

fn run(cli: Cli) -> anyhow::Result<u8> {
    let config_path = cli.config.clone().unwrap_or_else(config::default_config);
    let cfg = config::load(&config_path)?;
    let theme_key = cli.theme.clone().or(cfg.theme.clone());
    let theme = match theme_key.as_deref() {
        None => Name::Ayu,
        Some(key) => Name::parse(key)
            .ok_or_else(|| anyhow::anyhow!("unknown theme '{key}' (ayu, gruvbox)"))?,
    };

    let tty = io::stdout().is_terminal() && io::stdin().is_terminal();
    if !cli.headless && !tty {
        anyhow::bail!(",sync2 needs a terminal");
    }

    // No limit by default: fetches wait on the network, not the CPU.
    let jobs = cli.jobs.or(cfg.jobs).unwrap_or(usize::MAX);
    if jobs == 0 {
        anyhow::bail!("--jobs must be at least 1");
    }

    // Sources: -d/-f replace every default.
    let mut toml_repos = Vec::new();
    let (list_files, dirs): (Vec<PathBuf>, Vec<PathBuf>) =
        if cli.dirs.is_empty() && cli.files.is_empty() {
            let base = config_path.parent();
            toml_repos = cfg
                .repos
                .iter()
                .map(|r| config::expand_path(r, base))
                .collect();
            let dirs = if cfg.dirs.is_empty() {
                vec![config::default_dir()]
            } else {
                cfg.dirs
                    .iter()
                    .map(|d| config::expand_path(d, base))
                    .collect()
            };
            (vec![config::repo_list()], dirs)
        } else {
            (
                cli.files
                    .iter()
                    .map(|f| config::expand_path(f, None))
                    .collect(),
                cli.dirs
                    .iter()
                    .map(|d| config::expand_path(d, None))
                    .collect(),
            )
        };

    // Ignores from every place always apply.
    let mut ignores: Vec<String> = cli
        .ignores
        .iter()
        .map(|p| config::expand_ignore(p, None))
        .collect();
    ignores.extend(
        cfg.ignore
            .iter()
            .map(|p| config::expand_ignore(p, config_path.parent())),
    );
    ignores.extend(config::read_ignore_file(&config::ignore_list())?);

    let mut collected = sources::collect(&list_files, &dirs, &mut ignores);
    collected.repos.append(&mut toml_repos);
    let matcher = ignore::Ignores::new(ignores);
    let repos: Vec<PathBuf> = sources::dedup(collected.repos)
        .into_iter()
        .filter(|r| !matcher.matches(&r.to_string_lossy()))
        .collect();

    let opts = sync::Options {
        fetch_upstream_only: cli.fetch_upstream_only,
    };

    let (outcomes, unfinished, theme) = if cli.headless {
        let mut outcomes: Vec<Outcome> = collected
            .errors
            .iter()
            .map(|(subject, message)| Outcome {
                repo: PathBuf::from(subject),
                status: Status::Failed,
                message: message.clone(),
                dirty: None,
            })
            .collect();
        outcomes.extend(run_parallel(&repos, jobs, &opts));
        (outcomes, 0, theme)
    } else {
        let finish = tui::run(tui::Setup {
            repos,
            errors: collected.errors,
            jobs,
            opts,
            config_path,
            theme,
        })?;
        (finish.outcomes, finish.unfinished, finish.theme)
    };

    let report_theme = Theme::stdout(theme);
    let mut out = io::stdout().lock();
    print_report(&mut out, &report_theme, &outcomes)?;
    let mut counts = Counts::default();
    for o in &outcomes {
        counts.add(o.status);
    }
    let dirty = outcomes.iter().filter(|o| o.dirty == Some(true)).count();
    writeln!(out)?;
    ui::summary(&report_theme, &mut out, &counts, Some(dirty));
    if unfinished > 0 {
        writeln!(
            out,
            "{}",
            report_theme.paint(
                Role::Dim,
                &format!("{unfinished} repo(s) still syncing when you quit")
            )
        )?;
    }
    Ok(exit_code(&counts))
}

fn exit_code(counts: &Counts) -> u8 {
    if counts.failed > 0 {
        1
    } else if counts.attention > 0 {
        2
    } else {
        0
    }
}

/// Sync every repo on `jobs` worker threads, no UI. Returns outcomes sorted by path.
fn run_parallel(repos: &[PathBuf], jobs: usize, opts: &sync::Options) -> Vec<Outcome> {
    let queue = Arc::new(Mutex::new(repos.iter().cloned().collect::<VecDeque<_>>()));
    let (tx, rx) = mpsc::channel();
    let mut results = Vec::with_capacity(repos.len());
    thread::scope(|scope| {
        for _ in 0..jobs.min(repos.len().max(1)) {
            let queue = Arc::clone(&queue);
            let tx = tx.clone();
            scope.spawn(move || {
                loop {
                    let Some(repo) = queue.lock().expect("queue lock").pop_front() else {
                        break;
                    };
                    let outcome = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                        sync::sync_repo(&repo, opts, &|_| {})
                    }))
                    .unwrap_or_else(|_| Outcome {
                        repo: repo.clone(),
                        status: Status::Failed,
                        message: "Unexpected error".into(),
                        dirty: None,
                    });
                    let _ = tx.send(outcome);
                }
            });
        }
        drop(tx);
        results.extend(rx.iter());
    });
    results.retain(|r| r.status != Status::Skip);
    results.sort_by(|a, b| a.repo.cmp(&b.repo));
    results
}

/// Grouped report: Synced, Needs attention, Failed; empty sections hidden.
fn print_report(out: &mut dyn Write, theme: &Theme, results: &[Outcome]) -> io::Result<()> {
    let width = ui::column_width(results.iter().map(|r| r.repo.as_path()));
    let group = |keep: &dyn Fn(Status) -> bool| -> Vec<&Outcome> {
        results.iter().filter(|r| keep(r.status)).collect()
    };
    ui::section(out, theme, "Synced", &group(&|s| s.is_synced()), width)?;
    ui::section(
        out,
        theme,
        "Needs attention",
        &group(&|s| s == Status::Attention),
        width,
    )?;
    ui::section(
        out,
        theme,
        "Failed",
        &group(&|s| s == Status::Failed),
        width,
    )
}
