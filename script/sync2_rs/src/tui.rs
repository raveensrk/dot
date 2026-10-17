//! The `,sync2` TUI. Opens at once; the scan streams into it.
//!
//! Left: repos grouped Needs attention / Failed / Syncing / Synced. Right: the
//! selected repo (status, branch, last commit, changed files). Header: counts
//! and a progress bar. Finished rows are actionable while the scan runs.
//!
//! Keys: j/k move, g/G first/last, enter or y = lazygit then re-sync,
//! r = re-sync, i = ignore from now on, t = next theme (saved), ? = help,
//! q or esc = quit.
//!
//! A clean run (nothing needs attention, nothing failed) closes itself 1.5 s
//! after the last repo finishes, unless a key was pressed.

use std::collections::VecDeque;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::mpsc::{self, Receiver, Sender};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

use ratatui::crossterm::event::{self, Event, KeyCode, KeyEventKind, KeyModifiers};
use ratatui::layout::{Constraint, Flex, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::symbols;
use ratatui::text::{Line, Span};
use ratatui::widgets::{
    Block, BorderType, Clear, LineGauge, List, ListItem, ListState, Padding, Paragraph, Wrap,
};
use ratatui::{DefaultTerminal, Frame};
use tachyonfx::{EffectManager, Interpolation, Motion, fx};

use crate::config;
use crate::git::{self, Detail};
use crate::sync::{self, Outcome, Status};
use crate::theme::{Name, Palette, Rgb, Role};
use crate::ui;

const AUTO_EXIT: Duration = Duration::from_millis(1500);
const FLASH: Duration = Duration::from_millis(700);
const FRAME: Duration = Duration::from_millis(33);
const SPINNER: [&str; 10] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

pub struct Setup {
    pub repos: Vec<PathBuf>,
    /// Source errors (missing list file, unreadable dir): shown as failed rows.
    pub errors: Vec<(String, String)>,
    pub jobs: usize,
    pub opts: sync::Options,
    pub config_path: PathBuf,
    pub theme: Name,
}

pub struct Finish {
    /// Every finished, not ignored row, sorted by path.
    pub outcomes: Vec<Outcome>,
    /// Rows still syncing when the user quit.
    pub unfinished: usize,
    pub theme: Name,
}

enum Phase {
    Waiting,
    Running(String),
    Done,
}

struct Row {
    repo: PathBuf,
    phase: Phase,
    outcome: Option<Outcome>,
    detail: Detail,
    /// When the row last changed state; drives the flash.
    changed: Option<Instant>,
    /// A source error, not a repo: no actions.
    source_error: bool,
    ignored: bool,
}

impl Row {
    fn status(&self) -> Option<Status> {
        match self.phase {
            Phase::Done => self.outcome.as_ref().map(|o| o.status),
            _ => None,
        }
    }

    fn actionable(&self) -> bool {
        matches!(self.phase, Phase::Done) && !self.source_error && !self.ignored
    }
}

enum Msg {
    Step(usize, String),
    Done(usize, Box<Outcome>, Detail),
}

#[derive(Clone, Copy, PartialEq)]
enum Section {
    Attention,
    Failed,
    Syncing,
    Synced,
}

impl Section {
    const ORDER: [Section; 4] = [
        Section::Attention,
        Section::Failed,
        Section::Syncing,
        Section::Synced,
    ];

    fn title(self) -> &'static str {
        match self {
            Section::Attention => "Needs attention",
            Section::Failed => "Failed",
            Section::Syncing => "Syncing",
            Section::Synced => "Synced",
        }
    }

    fn of(row: &Row) -> Section {
        match row.status() {
            None => Section::Syncing,
            Some(Status::Attention) => Section::Attention,
            Some(Status::Failed) | Some(Status::Skip) => Section::Failed,
            Some(_) => Section::Synced,
        }
    }
}

enum ListLine {
    Header(Section, usize),
    Row(usize),
}

struct App {
    rows: Vec<Row>,
    selected: usize,
    list_state: ListState,
    theme: Name,
    note: String,
    help: bool,
    tx: Sender<Msg>,
    rx: Receiver<Msg>,
    opts: sync::Options,
    config_path: PathBuf,
    started: Instant,
    shown_ratio: f64,
    done_at: Option<Instant>,
    touched: bool,
    effects: EffectManager<()>,
    last_frame: Instant,
    header_area: Rect,
}

fn rgb((r, g, b): Rgb) -> Color {
    Color::Rgb(r, g, b)
}

fn lerp(a: Rgb, b: Rgb, t: f64) -> Rgb {
    let t = t.clamp(0.0, 1.0);
    let m = |x: u8, y: u8| (x as f64 + (y as f64 - x as f64) * t).round() as u8;
    (m(a.0, b.0), m(a.1, b.1), m(a.2, b.2))
}

/// Run the TUI until the user quits or a clean run closes itself.
pub fn run(setup: Setup) -> anyhow::Result<Finish> {
    let (tx, rx) = mpsc::channel();
    let mut rows: Vec<Row> = setup
        .errors
        .iter()
        .map(|(subject, message)| Row {
            repo: PathBuf::from(subject),
            phase: Phase::Done,
            outcome: Some(Outcome {
                repo: PathBuf::from(subject),
                status: Status::Failed,
                message: message.clone(),
                dirty: None,
            }),
            detail: Detail::default(),
            changed: None,
            source_error: true,
            ignored: false,
        })
        .collect();
    let first_repo = rows.len();
    rows.extend(setup.repos.iter().map(|repo| Row {
        repo: repo.clone(),
        phase: Phase::Waiting,
        outcome: None,
        detail: Detail::default(),
        changed: None,
        source_error: false,
        ignored: false,
    }));

    let queue: VecDeque<usize> = (first_repo..rows.len()).collect();
    spawn_workers(&rows, queue, setup.jobs, setup.opts, &tx);

    let mut app = App {
        rows,
        selected: 0,
        list_state: ListState::default(),
        theme: setup.theme,
        note: String::new(),
        help: false,
        tx,
        rx,
        opts: setup.opts,
        config_path: setup.config_path,
        started: Instant::now(),
        shown_ratio: 0.0,
        done_at: None,
        touched: false,
        effects: EffectManager::default(),
        last_frame: Instant::now(),
        header_area: Rect::default(),
    };
    let bg = rgb(app.palette().bg);
    app.effects.add_effect(fx::sweep_in(
        Motion::UpToDown,
        12,
        4,
        bg,
        (600, Interpolation::QuadOut),
    ));

    let mut terminal = ratatui::init();
    let result = event_loop(&mut terminal, &mut app);
    ratatui::restore();
    result?;

    let mut outcomes: Vec<Outcome> = app
        .rows
        .iter()
        .filter(|r| !r.ignored)
        .filter_map(|r| match r.phase {
            Phase::Done => r.outcome.clone(),
            _ => None,
        })
        .filter(|o| o.status != Status::Skip)
        .collect();
    outcomes.sort_by(|a, b| a.repo.cmp(&b.repo));
    let unfinished = app
        .rows
        .iter()
        .filter(|r| !matches!(r.phase, Phase::Done))
        .count();
    Ok(Finish {
        outcomes,
        unfinished,
        theme: app.theme,
    })
}

fn spawn_workers(
    rows: &[Row],
    queue: VecDeque<usize>,
    jobs: usize,
    opts: sync::Options,
    tx: &Sender<Msg>,
) {
    let paths: Arc<Vec<PathBuf>> = Arc::new(rows.iter().map(|r| r.repo.clone()).collect());
    let workers = jobs.min(queue.len());
    let queue = Arc::new(Mutex::new(queue));
    for _ in 0..workers {
        let queue = Arc::clone(&queue);
        let paths = Arc::clone(&paths);
        let tx = tx.clone();
        thread::spawn(move || {
            loop {
                let Some(i) = queue.lock().expect("queue lock").pop_front() else {
                    break;
                };
                sync_one(i, &paths[i], opts, &tx);
            }
        });
    }
}

/// Sync one repo, reporting steps; never panics past this point.
fn sync_one(i: usize, repo: &Path, opts: sync::Options, tx: &Sender<Msg>) {
    let step = |what: &str| {
        let _ = tx.send(Msg::Step(i, what.to_string()));
    };
    let outcome = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        sync::sync_repo(repo, &opts, &step)
    }))
    .unwrap_or_else(|_| Outcome {
        repo: repo.to_path_buf(),
        status: Status::Failed,
        message: "Unexpected error".into(),
        dirty: None,
    });
    let detail = if outcome.status == Status::Skip {
        Detail::default()
    } else {
        git::detail(repo)
    };
    let _ = tx.send(Msg::Done(i, Box::new(outcome), detail));
}

impl App {
    fn palette(&self) -> &'static Palette {
        self.theme.palette()
    }

    fn visible(&self, i: usize) -> bool {
        let r = &self.rows[i];
        !r.ignored && r.status() != Some(Status::Skip)
    }

    fn all_done(&self) -> bool {
        self.rows.iter().all(|r| matches!(r.phase, Phase::Done))
    }

    fn counts(&self) -> ui::Counts {
        let mut c = ui::Counts::default();
        for (i, r) in self.rows.iter().enumerate() {
            if let (true, Some(s)) = (self.visible(i), r.status()) {
                c.add(s);
            }
        }
        c
    }

    fn lines(&self) -> Vec<ListLine> {
        let mut out = Vec::new();
        for section in Section::ORDER {
            let mut members: Vec<usize> = (0..self.rows.len())
                .filter(|&i| self.visible(i) && Section::of(&self.rows[i]) == section)
                .collect();
            if members.is_empty() {
                continue;
            }
            members.sort_by(|&a, &b| self.rows[a].repo.cmp(&self.rows[b].repo));
            out.push(ListLine::Header(section, members.len()));
            out.extend(members.into_iter().map(ListLine::Row));
        }
        out
    }

    fn row_order(&self) -> Vec<usize> {
        self.lines()
            .into_iter()
            .filter_map(|l| match l {
                ListLine::Row(i) => Some(i),
                ListLine::Header(..) => None,
            })
            .collect()
    }

    fn move_by(&mut self, delta: isize) {
        let order = self.row_order();
        if order.is_empty() {
            return;
        }
        let pos = order.iter().position(|&i| i == self.selected).unwrap_or(0);
        let next = (pos as isize + delta).clamp(0, order.len() as isize - 1) as usize;
        self.selected = order[next];
    }

    fn select_edge(&mut self, last: bool) {
        let order = self.row_order();
        let pick = if last { order.last() } else { order.first() };
        if let Some(&i) = pick {
            self.selected = i;
        }
    }

    fn receive(&mut self) {
        while let Ok(msg) = self.rx.try_recv() {
            match msg {
                Msg::Step(i, what) => self.rows[i].phase = Phase::Running(what),
                Msg::Done(i, outcome, detail) => {
                    let row = &mut self.rows[i];
                    row.phase = Phase::Done;
                    row.outcome = Some(*outcome);
                    row.detail = detail;
                    row.changed = Some(Instant::now());
                }
            }
        }
        // Until the user moves, keep the top row (the first attention repo) selected.
        if !self.touched || !self.visible(self.selected) {
            self.select_edge(false);
        }
    }

    fn resync(&mut self, i: usize) {
        let row = &mut self.rows[i];
        row.phase = Phase::Running("queued".into());
        row.changed = Some(Instant::now());
        let (repo, opts, tx) = (row.repo.clone(), self.opts, self.tx.clone());
        self.note = format!("Re-syncing {}", ui::short(&repo));
        thread::spawn(move || sync_one(i, &repo, opts, &tx));
    }

    fn ignore(&mut self, i: usize) {
        let repo = self.rows[i].repo.to_string_lossy().into_owned();
        let saved = config::append_ignore_txt(&config::ignore_list(), &repo)
            .and_then(|()| config::append_ignore_toml(&self.config_path, &repo));
        match saved {
            Ok(()) => {
                self.rows[i].ignored = true;
                self.note = format!("{}: ignored on future runs", ui::short(&self.rows[i].repo));
                self.move_by(1);
                if !self.visible(self.selected) {
                    self.select_edge(false);
                }
            }
            Err(e) => self.note = format!("Could not update ignore list - {e:#}"),
        }
    }

    fn next_theme(&mut self) {
        let old_bg = rgb(self.palette().bg);
        self.theme = self.theme.next();
        self.effects
            .add_effect(fx::fade_from(old_bg, old_bg, (350, Interpolation::QuadOut)));
        self.note = match config::set_theme(&self.config_path, self.theme.key()) {
            Ok(()) => format!("Theme: {}", self.theme.label()),
            Err(e) => format!("Theme: {} (not saved - {e:#})", self.theme.label()),
        };
    }
}

fn open_lazygit(repo: &Path) -> bool {
    Command::new("lazygit")
        .arg("-p")
        .arg(repo)
        .status()
        .is_ok_and(|s| s.success())
}

fn event_loop(terminal: &mut DefaultTerminal, app: &mut App) -> anyhow::Result<()> {
    loop {
        app.receive();
        let counts = app.counts();
        if app.all_done() && app.done_at.is_none() {
            app.done_at = Some(Instant::now());
            let p = app.palette();
            let color = if counts.failed > 0 {
                p.fail
            } else if counts.attention > 0 {
                p.warn
            } else {
                p.ok
            };
            app.effects.add_effect(
                fx::fade_from_fg(rgb(color), (900, Interpolation::QuadOut))
                    .with_area(app.header_area),
            );
            app.note = format!("Done in {:.1} s", app.started.elapsed().as_secs_f64());
        }
        if let Some(done) = app.done_at
            && !app.touched
            && counts.attention == 0
            && counts.failed == 0
            && done.elapsed() >= AUTO_EXIT
        {
            return Ok(());
        }

        terminal.draw(|f| draw(f, app))?;

        if !event::poll(FRAME)? {
            continue;
        }
        let Event::Key(key) = event::read()? else {
            continue;
        };
        if key.kind != KeyEventKind::Press {
            continue;
        }
        app.touched = true;
        if app.help {
            app.help = false;
            continue;
        }
        let i = app.selected;
        let actionable = app.rows.get(i).is_some_and(Row::actionable);
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
            KeyCode::Char('c') if key.modifiers.contains(KeyModifiers::CONTROL) => return Ok(()),
            KeyCode::Char('j') | KeyCode::Down => app.move_by(1),
            KeyCode::Char('k') | KeyCode::Up => app.move_by(-1),
            KeyCode::Char('g') | KeyCode::Home => app.select_edge(false),
            KeyCode::Char('G') | KeyCode::End => app.select_edge(true),
            KeyCode::Char('t') => app.next_theme(),
            KeyCode::Char('?') => app.help = true,
            KeyCode::Enter | KeyCode::Char('y') if actionable => {
                let repo = app.rows[i].repo.clone();
                ratatui::restore();
                let ok = open_lazygit(&repo);
                *terminal = ratatui::init();
                terminal.clear()?;
                if ok {
                    app.resync(i);
                } else {
                    app.note = format!("{}: lazygit exited unsuccessfully", ui::short(&repo));
                }
            }
            KeyCode::Char('r') if actionable => app.resync(i),
            KeyCode::Char('i') if actionable => app.ignore(i),
            KeyCode::Enter | KeyCode::Char('y' | 'r' | 'i') => {
                app.note = "Wait for this repo to finish syncing".into();
            }
            _ => {}
        }
    }
}

fn draw(f: &mut Frame, app: &mut App) {
    let p = app.palette();
    let area = f.area();
    f.render_widget(
        Block::new().style(Style::default().bg(rgb(p.bg)).fg(rgb(p.fg))),
        area,
    );

    let [header, body, note, footer] = Layout::vertical([
        Constraint::Length(2),
        Constraint::Min(3),
        Constraint::Length(1),
        Constraint::Length(1),
    ])
    .areas(area);
    app.header_area = header;
    draw_header(f, app, header);

    let [left, right] =
        Layout::horizontal([Constraint::Percentage(58), Constraint::Percentage(42)]).areas(body);
    draw_list(f, app, left);
    draw_detail(f, app, right);

    f.render_widget(
        Paragraph::new(format!(" {}", app.note)).style(Style::default().fg(rgb(p.dim))),
        note,
    );
    let key = |k: &'static str, what: &'static str| {
        [
            Span::styled(format!(" {k} "), Style::default().fg(rgb(p.accent)).bold()),
            Span::styled(format!("{what}  "), Style::default().fg(rgb(p.dim))),
        ]
    };
    let keys: Vec<Span> = [
        key("enter", "lazygit"),
        key("r", "re-sync"),
        key("i", "ignore"),
        key("t", "theme"),
        key("?", "help"),
        key("q", "quit"),
    ]
    .into_iter()
    .flatten()
    .collect();
    f.render_widget(Paragraph::new(Line::from(keys)), footer);

    if app.help {
        draw_help(f, p, area);
    }

    let now = Instant::now();
    let elapsed = now - app.last_frame;
    app.last_frame = now;
    app.effects
        .process_effects(elapsed.into(), f.buffer_mut(), area);
}

fn draw_header(f: &mut Frame, app: &mut App, area: Rect) {
    let p = app.palette();
    let counts = app.counts();
    let total = (0..app.rows.len()).filter(|&i| app.visible(i)).count();
    let finished = counts.total();
    let target = if total == 0 {
        1.0
    } else {
        finished as f64 / total as f64
    };
    // Ease the bar toward the real ratio so it glides instead of jumping.
    app.shown_ratio += (target - app.shown_ratio) * 0.18;
    if (target - app.shown_ratio).abs() < 0.002 {
        app.shown_ratio = target;
    }

    let [top, bar] = Layout::vertical([Constraint::Length(1), Constraint::Length(1)]).areas(area);
    let n = |v: usize, c: Rgb| Span::styled(v.to_string(), Style::default().fg(rgb(c)).bold());
    let dim = |s: &'static str| Span::styled(s, Style::default().fg(rgb(p.dim)));
    let spin = if app.all_done() {
        Span::styled("●", Style::default().fg(rgb(p.ok)))
    } else {
        let frame = (app.started.elapsed().as_millis() / 80) as usize % SPINNER.len();
        Span::styled(SPINNER[frame], Style::default().fg(rgb(p.accent)))
    };
    let left = Line::from(vec![
        Span::raw(" "),
        spin,
        Span::styled(" ,sync2  ", Style::default().fg(rgb(p.accent)).bold()),
        n(counts.ok, p.ok),
        dim(" up-to-date  "),
        n(counts.pushed, p.push),
        dim(" pushed  "),
        n(counts.synced, p.push),
        dim(" synced  "),
        n(counts.attention, p.warn),
        dim(" attention  "),
        n(counts.failed, p.fail),
        dim(" failed"),
    ]);
    f.render_widget(Paragraph::new(left), top);
    f.render_widget(
        Paragraph::new(format!("{} ", app.theme.label()))
            .style(Style::default().fg(rgb(p.dim)))
            .right_aligned(),
        top,
    );
    f.render_widget(
        LineGauge::default()
            .ratio(app.shown_ratio.clamp(0.0, 1.0))
            .label(Span::styled(
                format!(" {finished}/{total} "),
                Style::default().fg(rgb(p.fg)),
            ))
            .filled_symbol(symbols::line::THICK_HORIZONTAL)
            .unfilled_symbol(symbols::line::HORIZONTAL)
            .filled_style(Style::default().fg(rgb(p.accent)))
            .unfilled_style(Style::default().fg(rgb(p.border))),
        bar,
    );
}

fn panel<'a>(p: &Palette, title: Line<'a>) -> Block<'a> {
    Block::bordered()
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(rgb(p.border)))
        .style(Style::default().bg(rgb(p.panel)))
        .title(title)
        .padding(Padding::horizontal(1))
}

fn draw_list(f: &mut Frame, app: &mut App, area: Rect) {
    let p = app.palette();
    let lines = app.lines();
    let width = ui::column_width(
        app.rows
            .iter()
            .enumerate()
            .filter(|(i, _)| app.visible(*i))
            .map(|(_, r)| r.repo.as_path()),
    );
    let tick = (app.started.elapsed().as_millis() / 80) as usize;
    let mut selected_line = None;
    let items: Vec<ListItem> = lines
        .iter()
        .enumerate()
        .map(|(n, line)| match line {
            ListLine::Header(section, count) => {
                let role = match section {
                    Section::Attention => Role::Warn,
                    Section::Failed => Role::Fail,
                    Section::Syncing => Role::Spinner,
                    Section::Synced => Role::Ok,
                };
                let heading = Line::from(vec![
                    Span::styled(section.title(), Style::default().fg(rgb(p.fg)).bold()),
                    Span::styled(
                        format!(" ({count})"),
                        Style::default().fg(rgb(p.role(role))),
                    ),
                ]);
                // A blank line above every heading but the first.
                if n == 0 {
                    ListItem::new(heading)
                } else {
                    ListItem::new(vec![Line::raw(""), heading])
                }
            }
            ListLine::Row(i) => {
                if *i == app.selected {
                    selected_line = Some(n);
                }
                row_item(p, &app.rows[*i], width, tick)
            }
        })
        .collect();
    app.list_state.select(selected_line);

    let title = Line::from(Span::styled(
        " Repositories ",
        Style::default().fg(rgb(p.fg)).bold(),
    ));
    let list = List::new(items)
        .block(panel(p, title))
        .highlight_style(Style::default().bg(rgb(p.select)))
        .highlight_symbol("▌")
        .scroll_padding(2);
    f.render_stateful_widget(list, area, &mut app.list_state);
}

fn row_item<'a>(p: &Palette, row: &Row, width: usize, tick: usize) -> ListItem<'a> {
    let path = format!("{:<width$}", ui::short(&row.repo));
    let flash = row
        .changed
        .map(|t| t.elapsed().as_secs_f64() / FLASH.as_secs_f64())
        .filter(|t| *t < 1.0);
    let (tag, tag_color, state, message) = match (&row.phase, &row.outcome) {
        (Phase::Done, Some(o)) => {
            let (t, role) = ui::tag(o.status);
            (
                format!("[{t}]"),
                p.role(role),
                ui::state(o.dirty).to_string(),
                o.message.clone(),
            )
        }
        (Phase::Running(what), _) => (
            format!("  {} ", SPINNER[tick % SPINNER.len()]),
            p.accent,
            String::new(),
            format!("{what}…"),
        ),
        _ => (
            "  ·  ".to_string(),
            p.dim,
            String::new(),
            "waiting".to_string(),
        ),
    };
    let text_color = match row.phase {
        Phase::Done => p.fg,
        _ => p.dim,
    };
    let mut style = Style::default();
    if let Some(t) = flash {
        // Flash: the row lights up in the accent color and fades back.
        style = style.bg(rgb(lerp(lerp(p.panel, p.accent, 0.35), p.panel, t)));
    }
    ListItem::new(Line::from(vec![
        Span::styled(
            format!("{tag:<6} "),
            Style::default().fg(rgb(tag_color)).bold(),
        ),
        Span::styled(format!("{path}  "), Style::default().fg(rgb(text_color))),
        Span::styled(
            format!("{state:<w$}  ", w = ui::STATE_WIDTH),
            Style::default().fg(rgb(p.dim)),
        ),
        Span::styled(message, Style::default().fg(rgb(text_color))),
    ]))
    .style(style)
}

fn draw_detail(f: &mut Frame, app: &App, area: Rect) {
    let p = app.palette();
    let label = |s: &'static str| Span::styled(format!("{s:<8}"), Style::default().fg(rgb(p.dim)));
    let Some(row) = app
        .rows
        .get(app.selected)
        .filter(|_| app.visible(app.selected))
    else {
        let title = Line::from(" Details ");
        f.render_widget(
            Paragraph::new("No repositories").block(panel(p, title)),
            area,
        );
        return;
    };
    let title = Line::from(Span::styled(
        format!(" {} ", ui::short(&row.repo)),
        Style::default().fg(rgb(p.accent)).bold(),
    ));
    let mut lines: Vec<Line> = Vec::new();
    match (&row.phase, &row.outcome) {
        (Phase::Done, Some(o)) => {
            let (t, role) = ui::tag(o.status);
            lines.push(Line::from(vec![
                label("status"),
                Span::styled(
                    format!("[{t}] "),
                    Style::default().fg(rgb(p.role(role))).bold(),
                ),
                Span::raw(o.message.clone()),
            ]));
            lines.push(Line::from(vec![
                label("tree"),
                Span::raw(ui::state(o.dirty)),
            ]));
        }
        (Phase::Running(what), _) => {
            lines.push(Line::from(vec![
                label("status"),
                Span::styled(format!("{what}…"), Style::default().fg(rgb(p.accent))),
            ]));
        }
        _ => lines.push(Line::from(vec![label("status"), Span::raw("waiting")])),
    }
    if row.source_error {
        f.render_widget(
            Paragraph::new(lines)
                .wrap(Wrap { trim: false })
                .block(panel(p, title)),
            area,
        );
        return;
    }
    if !row.detail.branch.is_empty() {
        lines.push(Line::from(vec![
            label("branch"),
            Span::styled(row.detail.branch.clone(), Style::default().fg(rgb(p.push))),
        ]));
    }
    if !row.detail.last_commit.is_empty() {
        lines.push(Line::from(vec![
            label("commit"),
            Span::raw(row.detail.last_commit.clone()),
        ]));
    }
    if !row.detail.files.is_empty() {
        lines.push(Line::raw(""));
        lines.push(Line::from(Span::styled(
            format!(
                "Changes ({})",
                row.detail.files.len() + row.detail.more_files
            ),
            Style::default().fg(rgb(p.fg)).add_modifier(Modifier::BOLD),
        )));
        for file in &row.detail.files {
            let (code, name) = file.split_at(file.len().min(2));
            let color = match code.trim() {
                "??" => p.dim,
                c if c.contains('D') => p.fail,
                c if c.contains('A') => p.ok,
                _ => p.warn,
            };
            lines.push(Line::from(vec![
                Span::styled(format!("{code:<3}"), Style::default().fg(rgb(color)).bold()),
                Span::raw(name.trim_start().to_string()),
            ]));
        }
        if row.detail.more_files > 0 {
            lines.push(Line::from(Span::styled(
                format!("… and {} more", row.detail.more_files),
                Style::default().fg(rgb(p.dim)),
            )));
        }
    }
    f.render_widget(
        Paragraph::new(lines)
            .wrap(Wrap { trim: false })
            .block(panel(p, title)),
        area,
    );
}

fn draw_help(f: &mut Frame, p: &Palette, area: Rect) {
    let keys = [
        ("j / k, ↓ / ↑", "move"),
        ("g / G", "first / last repo"),
        ("enter, y", "open lazygit, then re-sync"),
        ("r", "re-sync this repo"),
        ("i", "ignore this repo from now on"),
        ("t", "next theme (saved to sync2.toml)"),
        ("?", "this help"),
        ("q, esc", "quit and print the report"),
    ];
    let lines: Vec<Line> = keys
        .iter()
        .map(|(k, what)| {
            Line::from(vec![
                Span::styled(
                    format!("{k:<14}"),
                    Style::default().fg(rgb(p.accent)).bold(),
                ),
                Span::raw(*what),
            ])
        })
        .collect();
    let [popup] = Layout::horizontal([Constraint::Length(52)])
        .flex(Flex::Center)
        .areas(area);
    let [popup] = Layout::vertical([Constraint::Length(lines.len() as u16 + 4)])
        .flex(Flex::Center)
        .areas(popup);
    f.render_widget(Clear, popup);
    let title = Line::from(Span::styled(
        " Keys ",
        Style::default().fg(rgb(p.fg)).bold(),
    ));
    f.render_widget(
        Paragraph::new(lines).block(
            panel(p, title)
                .padding(Padding::uniform(1))
                .style(Style::default().bg(rgb(p.panel)).fg(rgb(p.fg))),
        ),
        popup,
    );
}
