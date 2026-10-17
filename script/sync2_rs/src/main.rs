//! `,sync2`: sync many git repositories in parallel. Rust rewrite of
//! `script/legacy/,sync.py`, which stays as the legacy tool.
//!
//! Output rows: `[TAG]  <path>  <state>  <message>`. Tags: OK, PUSH, SYNC
//! (synced), WARN (needs attention), FAIL. State is clean, dirty or '-'.
//!
//! Subcommands:
//!   ,sync2          sync, report, then a triage view (src/tui.rs) of repos
//!                   needing attention: lazygit + re-sync, ignore, done.
//!                   `--plain` or NO_COLOR: per-repo prompt instead:
//!                   y = lazygit, n = leave it, i = ignore from now on, q = stop
//!   ,sync2 list     non-interactive: stdout holds only '<path>  <reason>' lines
//!                   for repos to open in lazygit; everything else on stderr
//!   ,sync2 manual   open every repo in lazygit; no fetch, merge or push
//!   ,sync2 ignore P add P to both ignore lists
//!
//! Per repo: not a repo, submodule or ignored -> skipped silently. Detached
//! HEAD -> attention. No upstream, or upstream gone after fetch -> OK if clean,
//! attention if dirty. Local ('.') upstream -> attention. `git fetch --all`
//! fails -> FAIL. Dirty -> attention. Diverged -> attention. Ahead only ->
//! push HEAD:<merge ref>. Behind only -> `merge --ff-only`, then
//! `submodule update --recursive` (no --init); failure -> attention.
//!
//! Sources: `~/dot_local/sync2.toml` (`jobs`, `repos`, `dirs`, `ignore`),
//! `~/dot_local/list_of_repos.txt` (paths, `dir:` and `ignore:` lines) and
//! `~/repos` (or the TOML `dirs`). `-d`/`-f` replace every default source.
//! Ignores from the TOML, `~/dot_local/list_of_ignores.txt`, `ignore:` lines
//! and `-i` always apply. A plain path skips everything beneath it; a glob
//! matches shell-style (`*` crosses '/'). Answering `i` writes both files.
//!
//! Report: sections Synced, Needs attention and Failed, each with a heading
//! and count, rows sorted by path; empty sections are hidden.
//!
//! On a TTY: per-repo spinners and an overall bar during the scan, and a
//! summary that counts up. Off a TTY, in `list`, or with NO_COLOR: plain rows.
//! Colors: Gruvbox dark hard (src/theme.rs).
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
use std::io::{self, BufRead, IsTerminal, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};
use std::sync::{Arc, Mutex, mpsc};
use std::thread;

use clap::{Parser, Subcommand};

use crate::sync::{Outcome, Status};
use crate::theme::{Role, Theme};
use crate::ui::Counts;

#[derive(Parser)]
#[command(name = ",sync2", about = "Sync many git repositories in parallel.")]
struct Cli {
    #[command(subcommand)]
    command: Option<Cmd>,
    /// Repositories to sync concurrently (default: config `jobs`, else all at once).
    #[arg(short, long, value_name = "N", global = true)]
    jobs: Option<usize>,
    /// Config file (default: ~/dot_local/sync2.toml).
    #[arg(short, long, value_name = "FILE", global = true)]
    config: Option<PathBuf>,
    /// Directory to scan for repos (repeatable; replaces default sources).
    #[arg(short, long = "dir", value_name = "DIR", global = true)]
    dirs: Vec<String>,
    /// List file of repo paths, 'dir:' and 'ignore:' lines (repeatable; replaces default sources).
    #[arg(short, long = "file", value_name = "FILE", global = true)]
    files: Vec<String>,
    /// Path or glob to skip (repeatable).
    #[arg(short, long = "ignore", value_name = "PAT", global = true)]
    ignores: Vec<String>,
    /// Report only; never prompt.
    #[arg(short = 'y', long, global = true)]
    no_prompt: bool,
    /// Use the y/n/i/q line prompt instead of the triage view.
    #[arg(long, global = true)]
    plain: bool,
    /// Fetch only the upstream remote, like ,sync.py (for benchmarks).
    #[arg(long, hide = true, global = true)]
    fetch_upstream_only: bool,
}

#[derive(Subcommand)]
enum Cmd {
    /// Sync, then print only the repos to open in lazygit on stdout.
    List,
    /// Open every repository in lazygit; no fetch, merge or push.
    Manual,
    /// Add a path to both ignore lists.
    Ignore { path: String },
}

#[derive(PartialEq)]
enum Mode {
    Sync,
    List,
    Manual,
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    match run(cli) {
        Ok(code) => ExitCode::from(code),
        Err(e) => {
            eprintln!(
                "{}",
                Theme::stderr().paint(Role::Fail, &format!("[FAIL]  {e:#}"))
            );
            ExitCode::from(1)
        }
    }
}

fn run(cli: Cli) -> anyhow::Result<u8> {
    let config_path = cli.config.clone().unwrap_or_else(config::default_config);
    let cfg = config::load(&config_path)?;

    let mode = match &cli.command {
        None => Mode::Sync,
        Some(Cmd::List) => Mode::List,
        Some(Cmd::Manual) => Mode::Manual,
        Some(Cmd::Ignore { path }) => return ignore_command(path, &config_path),
    };
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

    // In list mode stdout carries only the list.
    let report_theme = if mode == Mode::List {
        Theme::stderr()
    } else {
        Theme::stdout()
    };
    let mut report: Box<dyn Write> = if mode == Mode::List {
        Box::new(io::stderr())
    } else {
        Box::new(io::stdout())
    };

    let mut counts = Counts::default();
    for (subject, message) in &collected.errors {
        counts.failed += 1;
        writeln!(
            report,
            "{}",
            ui::row(
                &report_theme,
                "FAIL",
                Role::Fail,
                &ui::short(Path::new(subject)),
                0,
                None,
                message
            )
        )?;
    }

    if mode == Mode::Manual {
        run_manual(&repos, &report_theme, &mut counts);
        writeln!(report)?;
        ui::summary(&report_theme, &mut report, &counts, None, false);
        return Ok(exit_code(&counts));
    }

    let opts = sync::Options {
        fetch_upstream_only: cli.fetch_upstream_only,
    };
    let live = mode == Mode::Sync && io::stdout().is_terminal() && report_theme.enabled();
    let mut results = run_parallel(&repos, jobs, &opts, live.then_some(report_theme));
    for r in &results {
        counts.add(r.status);
    }
    let mut dirty_total = results.iter().filter(|r| r.dirty == Some(true)).count();

    match mode {
        Mode::List => print_list(&results)?,
        _ => print_report(&mut report, &report_theme, &results)?,
    }

    let interactive = mode == Mode::Sync && !cli.no_prompt && io::stdin().is_terminal();
    if interactive && !cli.plain && report_theme.enabled() {
        let attention: Vec<Outcome> = results
            .iter()
            .filter(|r| r.status == Status::Attention)
            .map(Outcome::clone)
            .collect();
        if !attention.is_empty() {
            let triaged = tui::triage(
                attention,
                &opts,
                &|repo| add_ignore(repo, &config_path),
                &open_lazygit,
            )?;
            for t in triaged {
                if let Some(r) = results.iter_mut().find(|r| r.repo == t.repo) {
                    *r = t;
                }
            }
            results.retain(|r| r.status != Status::Skip);
            counts = Counts::default();
            counts.failed = collected.errors.len();
            for r in &results {
                counts.add(r.status);
            }
            dirty_total = results.iter().filter(|r| r.dirty == Some(true)).count();
            // After triage, show only what is still open.
            let open: Vec<&Outcome> = results
                .iter()
                .filter(|r| matches!(r.status, Status::Attention | Status::Failed))
                .collect();
            let width = ui::column_width(open.iter().map(|r| r.repo.as_path()));
            ui::section(
                &mut report,
                &report_theme,
                "Still open after triage",
                &open,
                width,
            )?;
        }
    } else if interactive {
        let failures = prompt_for_attention(&results, &report_theme, &config_path)?;
        counts.attention -= failures;
        counts.failed += failures;
    }

    if mode != Mode::List {
        writeln!(report)?;
    }
    ui::summary(&report_theme, &mut report, &counts, Some(dirty_total), live);
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

/// Sync every repo on `jobs` worker threads. Returns outcomes sorted by path.
fn run_parallel(
    repos: &[PathBuf],
    jobs: usize,
    opts: &sync::Options,
    live: Option<Theme>,
) -> Vec<Outcome> {
    let live = live.map(|theme| ui::Live::new(theme, repos.len()));
    let queue = Arc::new(Mutex::new(repos.iter().cloned().collect::<VecDeque<_>>()));
    let (tx, rx) = mpsc::channel();

    let mut results = Vec::with_capacity(repos.len());
    thread::scope(|scope| {
        for _ in 0..jobs.min(repos.len().max(1)) {
            let queue = Arc::clone(&queue);
            let tx = tx.clone();
            let live = live.clone();
            scope.spawn(move || {
                let bar = live.as_ref().map(|l| l.spinner());
                loop {
                    let Some(repo) = queue.lock().expect("queue lock").pop_front() else {
                        break;
                    };
                    let step = |what: &str| {
                        if let (Some(l), Some(b)) = (&live, &bar) {
                            l.step(b, &repo, what);
                        }
                    };
                    let outcome = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                        sync::sync_repo(&repo, opts, &step)
                    }))
                    .unwrap_or_else(|_| Outcome {
                        repo: repo.clone(),
                        status: Status::Failed,
                        message: "Unexpected error".into(),
                        dirty: None,
                    });
                    if let Some(l) = &live {
                        l.finish();
                    }
                    let _ = tx.send(outcome);
                }
                if let Some(b) = bar {
                    b.finish_and_clear();
                }
            });
        }
        drop(tx);
        results.extend(rx.iter());
    });
    if let Some(l) = &live {
        l.close();
    }
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

/// `list`: repos to open in lazygit on stdout, failures on stderr.
fn print_list(results: &[Outcome]) -> io::Result<()> {
    let attention: Vec<_> = results
        .iter()
        .filter(|r| r.status == Status::Attention)
        .collect();
    let failed: Vec<_> = results
        .iter()
        .filter(|r| r.status == Status::Failed)
        .collect();
    let width = ui::column_width(attention.iter().map(|r| r.repo.as_path()));
    let mut stdout = io::stdout().lock();
    for r in &attention {
        writeln!(stdout, "{:<width$}  {}", ui::short(&r.repo), r.message)?;
    }
    let theme = Theme::stderr();
    let fwidth = ui::column_width(failed.iter().map(|r| r.repo.as_path()));
    for r in &failed {
        eprintln!("{}", ui::outcome_row(&theme, r, fwidth));
    }
    Ok(())
}

fn open_lazygit(repo: &Path) -> bool {
    Command::new("lazygit")
        .arg("-p")
        .arg(repo)
        .status()
        .is_ok_and(|s| s.success())
}

/// Per repo needing attention: y = lazygit, n = leave, i = ignore, q = stop.
/// Returns how many lazygit runs failed.
fn prompt_for_attention(
    results: &[Outcome],
    theme: &Theme,
    config_path: &Path,
) -> anyhow::Result<usize> {
    let attention: Vec<_> = results
        .iter()
        .filter(|r| r.status == Status::Attention)
        .collect();
    if attention.is_empty() {
        return Ok(0);
    }
    let pad = " ".repeat(8);
    let width = ui::column_width(attention.iter().map(|r| r.repo.as_path()));
    println!("\n{pad}y = open in lazygit    n = leave it for now (default)");
    println!("{pad}i = ignore this repo from now on    q = quit, leave the rest alone");
    let stdin = io::stdin();
    let mut failures = 0;
    for r in attention {
        println!("\n{}", ui::outcome_row(theme, r, width));
        print!("{pad}Action? [y/N/i/q] ");
        io::stdout().flush()?;
        let mut answer = String::new();
        if stdin.lock().read_line(&mut answer)? == 0 {
            println!();
            break;
        }
        match answer.trim().to_lowercase().as_str() {
            "q" | "quit" => break,
            "i" | "ignore" => {
                let repo = r.repo.to_string_lossy();
                match add_ignore(&repo, config_path) {
                    Ok(()) => println!(
                        "{}",
                        ui::row(
                            theme,
                            " OK ",
                            Role::Ok,
                            &ui::short(&r.repo),
                            0,
                            None,
                            "Ignored on future runs"
                        )
                    ),
                    Err(e) => println!(
                        "{}",
                        ui::row(
                            theme,
                            "FAIL",
                            Role::Fail,
                            &ui::short(&r.repo),
                            0,
                            None,
                            &format!("Could not update ignore list - {e:#}")
                        )
                    ),
                }
            }
            "y" | "yes" if !open_lazygit(&r.repo) => {
                println!(
                    "{}",
                    ui::row(
                        theme,
                        "FAIL",
                        Role::Fail,
                        &ui::short(&r.repo),
                        0,
                        None,
                        "lazygit exited unsuccessfully"
                    )
                );
                failures += 1;
            }
            _ => {}
        }
    }
    Ok(failures)
}

fn add_ignore(repo: &str, config_path: &Path) -> anyhow::Result<()> {
    config::append_ignore_txt(&config::ignore_list(), repo)?;
    config::append_ignore_toml(config_path, repo)
}

fn ignore_command(path: &str, config_path: &Path) -> anyhow::Result<u8> {
    let expanded = config::expand_path(path, std::env::current_dir().ok().as_deref());
    let resolved = std::fs::canonicalize(&expanded).unwrap_or(expanded);
    let repo = resolved.to_string_lossy();
    add_ignore(&repo, config_path)?;
    let theme = Theme::stdout();
    println!(
        "{}",
        ui::row(
            &theme,
            " OK ",
            Role::Ok,
            &ui::short(&resolved),
            0,
            None,
            "Ignored on future runs"
        )
    );
    Ok(0)
}

/// Open every repo in lazygit, one at a time.
fn run_manual(repos: &[PathBuf], theme: &Theme, counts: &mut Counts) {
    for repo in repos {
        if !matches!(git::open(repo), git::Open::Repo(_)) {
            continue;
        }
        println!(
            "{}",
            ui::row(
                theme,
                "SCAN",
                Role::Ok,
                &ui::short(repo),
                0,
                None,
                "Opening lazygit for manual handling"
            )
        );
        if open_lazygit(repo) {
            counts.manual += 1;
        } else {
            counts.failed += 1;
            println!(
                "{}",
                ui::row(
                    theme,
                    "FAIL",
                    Role::Fail,
                    &ui::short(repo),
                    0,
                    None,
                    "lazygit exited unsuccessfully"
                )
            );
        }
    }
}
