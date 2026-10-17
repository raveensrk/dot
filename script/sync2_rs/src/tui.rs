//! Triage view for repos that need attention, shown after a sync on a TTY.
//! Replaces the y/n/i/q prompt: pick repos in any order, open lazygit, and
//! see the repo re-synced when lazygit exits.
//!
//! Keys: j/k or arrows move, enter or y = lazygit then re-sync, r = re-sync,
//! i = ignore from now on, q or esc = done.

use std::path::Path;

use ratatui::crossterm::event::{self, Event, KeyCode, KeyEventKind, KeyModifiers};
use ratatui::layout::{Constraint, Layout};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, List, ListItem, ListState, Paragraph};
use ratatui::{DefaultTerminal, Frame};

use crate::sync::{self, Outcome, Status};
use crate::theme::{self, Role};
use crate::ui;

struct App {
    rows: Vec<Outcome>,
    state: ListState,
    note: String,
}

fn color(role: Role) -> Color {
    let (r, g, b) = theme::rgb(role);
    Color::Rgb(r, g, b)
}

/// Run the triage view over `rows` (the attention repos). Returns the rows
/// with their final status: re-synced, Failed if lazygit failed, Skip if
/// ignored. `ignore` writes a repo to the ignore lists.
pub fn triage(
    rows: Vec<Outcome>,
    opts: &sync::Options,
    ignore: &dyn Fn(&str) -> anyhow::Result<()>,
    lazygit: &dyn Fn(&Path) -> bool,
) -> anyhow::Result<Vec<Outcome>> {
    let mut app = App {
        rows,
        state: ListState::default().with_selected(Some(0)),
        note: String::new(),
    };
    let mut terminal = ratatui::init();
    let result = event_loop(&mut terminal, &mut app, opts, ignore, lazygit);
    ratatui::restore();
    result.map(|()| app.rows)
}

fn event_loop(
    terminal: &mut DefaultTerminal,
    app: &mut App,
    opts: &sync::Options,
    ignore: &dyn Fn(&str) -> anyhow::Result<()>,
    lazygit: &dyn Fn(&Path) -> bool,
) -> anyhow::Result<()> {
    loop {
        terminal.draw(|f| draw(f, app))?;
        let Event::Key(key) = event::read()? else {
            continue;
        };
        if key.kind != KeyEventKind::Press {
            continue;
        }
        let i = app.state.selected().unwrap_or(0);
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
            KeyCode::Char('c') if key.modifiers.contains(KeyModifiers::CONTROL) => return Ok(()),
            KeyCode::Char('j') | KeyCode::Down => app.state.select_next(),
            KeyCode::Char('k') | KeyCode::Up => app.state.select_previous(),
            KeyCode::Char('g') | KeyCode::Home => app.state.select_first(),
            KeyCode::Char('G') | KeyCode::End => app.state.select_last(),
            KeyCode::Enter | KeyCode::Char('y') if app.rows[i].status != Status::Skip => {
                let repo = app.rows[i].repo.clone();
                ratatui::restore();
                let ok = lazygit(&repo);
                *terminal = ratatui::init();
                if ok {
                    resync(terminal, app, i, opts)?;
                } else {
                    app.rows[i].status = Status::Failed;
                    app.rows[i].message = "lazygit exited unsuccessfully".into();
                    app.note = format!("{}: lazygit failed", ui::short(&repo));
                }
            }
            KeyCode::Char('r') if app.rows[i].status != Status::Skip => {
                resync(terminal, app, i, opts)?;
            }
            KeyCode::Char('i') if app.rows[i].status != Status::Skip => {
                let repo = app.rows[i].repo.to_string_lossy().into_owned();
                match ignore(&repo) {
                    Ok(()) => {
                        app.rows[i].status = Status::Skip;
                        app.rows[i].message = "Ignored on future runs".into();
                        app.note = format!("{}: ignored", ui::short(&app.rows[i].repo));
                    }
                    Err(e) => app.note = format!("Could not update ignore list - {e:#}"),
                }
            }
            _ => {}
        }
    }
}

fn resync(
    terminal: &mut DefaultTerminal,
    app: &mut App,
    i: usize,
    opts: &sync::Options,
) -> anyhow::Result<()> {
    app.note = format!("Re-syncing {} ...", ui::short(&app.rows[i].repo));
    terminal.draw(|f| draw(f, app))?;
    let fresh = sync::sync_repo(&app.rows[i].repo, opts, &|_| {});
    app.note = format!("{}: {}", ui::short(&fresh.repo), fresh.message);
    app.rows[i] = fresh;
    Ok(())
}

fn draw(f: &mut Frame, app: &mut App) {
    let [list_area, note_area, help_area] = Layout::vertical([
        Constraint::Min(1),
        Constraint::Length(1),
        Constraint::Length(1),
    ])
    .areas(f.area());

    let width = ui::column_width(app.rows.iter().map(|r| r.repo.as_path()));
    let open = app
        .rows
        .iter()
        .filter(|r| matches!(r.status, Status::Attention | Status::Failed))
        .count();
    let items: Vec<ListItem> = app
        .rows
        .iter()
        .map(|r| {
            let (tag, role) = match r.status {
                Status::Skip => ("IGNR", Role::Dim),
                s => ui::tag(s),
            };
            let dim = Style::default().fg(color(Role::Dim));
            ListItem::new(Line::from(vec![
                Span::styled(format!("[{tag}]  "), Style::default().fg(color(role))),
                Span::raw(format!("{:<width$}  ", ui::short(&r.repo))),
                Span::styled(format!("{:<5}  ", ui::state(r.dirty)), dim),
                Span::raw(r.message.clone()),
            ]))
        })
        .collect();
    let title = format!(" Needs attention: {open} of {} ", app.rows.len());
    let list = List::new(items)
        .block(Block::bordered().title(title))
        .highlight_style(Style::default().add_modifier(Modifier::REVERSED))
        .highlight_symbol("> ");
    f.render_stateful_widget(list, list_area, &mut app.state);

    f.render_widget(Paragraph::new(app.note.as_str()), note_area);
    f.render_widget(
        Paragraph::new("enter/y lazygit   r re-sync   i ignore   j/k move   q done")
            .style(Style::default().fg(color(Role::Dim))),
        help_area,
    );
}
