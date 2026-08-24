use anyhow::{Context, Result};
use clap::Parser;
use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Wrap},
    Frame, Terminal,
};
use serde::Deserialize;
use std::{
    io,
    time::{Duration, Instant},
};

#[derive(Debug, Parser)]
#[command(
    name = "gh.runs",
    bin_name = "gh.runs",
    about = "Monitor GitHub Actions runs"
)]
struct Cli {
    /// Repository to inspect. Defaults to the repository in the current directory.
    #[arg(short = 'R', long, value_name = "OWNER/REPO")]
    repo: Option<String>,
}

const REFRESH_INTERVAL: Duration = Duration::from_secs(10);
const RUN_LIMIT: &str = "20";
const RUN_FIELDS: &str = "databaseId,name,displayTitle,headBranch,status,conclusion,event,createdAt,startedAt,updatedAt,url";

#[derive(Clone, Debug, Deserialize)]
struct Run {
    #[serde(rename = "databaseId")]
    id: u64,
    name: String,
    #[serde(rename = "displayTitle")]
    display_title: String,
    #[serde(rename = "headBranch")]
    head_branch: String,
    status: String,
    conclusion: Option<String>,
    event: String,
    #[serde(rename = "createdAt")]
    created_at: String,
    #[serde(rename = "startedAt")]
    started_at: Option<String>,
    #[serde(rename = "updatedAt")]
    updated_at: String,
    url: String,
}

fn sort_latest(runs: &mut [Run]) {
    runs.sort_by(|left, right| right.created_at.cmp(&left.created_at));
}

mod github {
    use super::{sort_latest, Run, RUN_FIELDS, RUN_LIMIT};
    use anyhow::{bail, Context, Result};
    use serde_json::Value;
    use std::process::Command;

    pub fn current_runs(repo: Option<&str>) -> Result<Vec<Run>> {
        let mut runs = list_runs(repo)?;
        sort_latest(&mut runs);
        Ok(runs)
    }

    pub fn repository_name(repo: Option<&str>) -> String {
        let mut command = Command::new("gh");
        command.args(["repo", "view"]);
        add_repo_filter(&mut command, repo);
        command.args(["--json", "nameWithOwner"]);
        let output = command.output();
        let Ok(output) = output else {
            return "current repository".to_owned();
        };
        if !output.status.success() {
            return "current repository".to_owned();
        }

        serde_json::from_slice::<Value>(&output.stdout)
            .ok()
            .and_then(|value| value["nameWithOwner"].as_str().map(str::to_owned))
            .filter(|name| !name.is_empty())
            .unwrap_or_else(|| repo.unwrap_or("current repository").to_owned())
    }

    pub fn open_run(run_id: u64, repo: Option<&str>) -> Result<()> {
        let mut command = Command::new("gh");
        command.args(["run", "view", "--web"]);
        add_repo_filter(&mut command, repo);
        let status = command
            .arg(run_id.to_string())
            .status()
            .context("failed to start gh run view")?;
        if !status.success() {
            bail!("gh run view --web exited with {status}");
        }
        Ok(())
    }

    fn list_runs(repo: Option<&str>) -> Result<Vec<Run>> {
        let mut command = Command::new("gh");
        command.args(["run", "list", "--limit", RUN_LIMIT]);
        add_repo_filter(&mut command, repo);
        let output = command
            .args(["--json", RUN_FIELDS])
            .output()
            .context("failed to start gh run list")?;

        if !output.status.success() {
            let detail = String::from_utf8_lossy(&output.stderr);
            let detail = detail.trim();
            if detail.is_empty() {
                bail!("gh run list exited with {}", output.status);
            }
            bail!("gh run list failed: {detail}");
        }

        serde_json::from_slice(&output.stdout).context("gh returned invalid JSON for runs")
    }

    fn add_repo_filter(command: &mut Command, repo: Option<&str>) {
        if let Some(repo) = repo {
            command.args(["--repo", repo]);
        }
    }
}

struct App {
    repo: String,
    repo_filter: Option<String>,
    runs: Vec<Run>,
    selected: usize,
    message: Option<String>,
    last_refresh: Instant,
}

impl App {
    fn new(repo: String, repo_filter: Option<String>, runs: Vec<Run>) -> Self {
        Self {
            repo,
            repo_filter,
            runs,
            selected: 0,
            message: None,
            last_refresh: Instant::now(),
        }
    }

    fn refresh(&mut self) {
        let selected_id = self.runs.get(self.selected).map(|run| run.id);
        match github::current_runs(self.repo_filter.as_deref()) {
            Ok(runs) => {
                self.runs = runs;
                self.selected = selected_id
                    .and_then(|id| self.runs.iter().position(|run| run.id == id))
                    .unwrap_or(0)
                    .min(self.runs.len().saturating_sub(1));
                self.message = None;
            }
            Err(error) => {
                self.message = Some(format!("Refresh failed: {error}"));
            }
        }
        self.last_refresh = Instant::now();
    }

    fn move_selection(&mut self, offset: isize) {
        if self.runs.is_empty() {
            return;
        }
        let last = self.runs.len() - 1;
        self.selected = if offset.is_negative() {
            self.selected.saturating_sub(offset.unsigned_abs())
        } else {
            self.selected.saturating_add(offset as usize).min(last)
        };
    }

    fn selected_run(&self) -> Option<&Run> {
        self.runs.get(self.selected)
    }
}

enum Action {
    Quit,
    Open(u64),
}

struct TerminalSession {
    terminal: Terminal<CrosstermBackend<io::Stdout>>,
}

impl TerminalSession {
    fn new() -> Result<Self> {
        enable_raw_mode().context("failed to enable raw mode")?;
        let mut stdout = io::stdout();
        if let Err(error) = execute!(stdout, EnterAlternateScreen) {
            let _ = disable_raw_mode();
            return Err(error).context("failed to enter the alternate screen");
        }

        let terminal = match Terminal::new(CrosstermBackend::new(stdout)) {
            Ok(terminal) => terminal,
            Err(error) => {
                let _ = disable_raw_mode();
                let mut stdout = io::stdout();
                let _ = execute!(stdout, LeaveAlternateScreen);
                return Err(error).context("failed to create terminal");
            }
        };
        Ok(Self { terminal })
    }
}

impl Drop for TerminalSession {
    fn drop(&mut self) {
        let _ = disable_raw_mode();
        let _ = execute!(self.terminal.backend_mut(), LeaveAlternateScreen);
        let _ = self.terminal.show_cursor();
    }
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    let repo_filter = cli.repo;
    let mut app = App::new(
        github::repository_name(repo_filter.as_deref()),
        repo_filter.clone(),
        github::current_runs(repo_filter.as_deref())?,
    );

    loop {
        match run_tui(&mut app)? {
            Action::Quit => return Ok(()),
            Action::Open(run_id) => {
                let result = github::open_run(run_id, app.repo_filter.as_deref());
                app.refresh();
                app.message = Some(match result {
                    Ok(()) => format!("Opened run #{run_id} in the browser"),
                    Err(error) => format!("Could not open run #{run_id}: {error}"),
                });
            }
        }
    }
}

fn run_tui(app: &mut App) -> Result<Action> {
    let mut session = TerminalSession::new()?;
    let result = event_loop(&mut session.terminal, app);
    drop(session);
    result
}

fn event_loop(
    terminal: &mut Terminal<CrosstermBackend<io::Stdout>>,
    app: &mut App,
) -> Result<Action> {
    loop {
        terminal.draw(|frame| draw(frame, app))?;

        let now = Instant::now();
        let timeout = REFRESH_INTERVAL.saturating_sub(now.duration_since(app.last_refresh));
        if event::poll(timeout)? {
            let Event::Key(key) = event::read()? else {
                continue;
            };
            if key.kind != KeyEventKind::Press {
                continue;
            }
            match key.code {
                KeyCode::Char('q') | KeyCode::Esc => return Ok(Action::Quit),
                KeyCode::Enter => {
                    if let Some(run) = app.selected_run() {
                        return Ok(Action::Open(run.id));
                    }
                }
                KeyCode::Char('j') | KeyCode::Down => app.move_selection(1),
                KeyCode::Char('k') | KeyCode::Up => app.move_selection(-1),
                KeyCode::Char('g') => app.selected = 0,
                KeyCode::Char('G') => {
                    app.selected = app.runs.len().saturating_sub(1);
                }
                KeyCode::Char('r') => app.refresh(),
                _ => {}
            }
        } else {
            app.refresh();
        }
    }
}

fn draw(frame: &mut Frame<'_>, app: &App) {
    let rows = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(2),
            Constraint::Min(5),
            Constraint::Length(1),
        ])
        .split(frame.area());

    let header = Paragraph::new(Line::from(vec![
        Span::styled(
            " gh.runs ",
            Style::default()
                .fg(Color::Black)
                .bg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        ),
        Span::raw(format!("  {}", app.repo)),
    ]))
    .block(Block::default().borders(Borders::BOTTOM));
    frame.render_widget(header, rows[0]);

    let columns = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(45), Constraint::Percentage(55)])
        .split(rows[1]);
    draw_run_list(frame, app, columns[0]);
    draw_details(frame, app, columns[1]);
    draw_help(frame, app, rows[2]);
}

fn draw_run_list(frame: &mut Frame<'_>, app: &App, area: Rect) {
    let items = app.runs.iter().map(run_item).collect::<Vec<_>>();
    let list = List::new(items)
        .block(
            Block::default()
                .title(format!(" LATEST RUNS · {} ", app.runs.len()))
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Cyan)),
        )
        .highlight_style(
            Style::default()
                .fg(Color::White)
                .bg(Color::DarkGray)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("› ");
    let mut state = ListState::default();
    if !app.runs.is_empty() {
        state.select(Some(app.selected));
    }
    frame.render_stateful_widget(list, area, &mut state);
}

fn run_item(run: &Run) -> ListItem<'static> {
    let status_color = status_color(&run.status, run.conclusion.as_deref());
    ListItem::new(vec![
        Line::from(vec![
            Span::styled(
                format!("● {} ", run.status),
                Style::default().fg(status_color),
            ),
            Span::styled(format!("#{}", run.id), Style::default().fg(Color::DarkGray)),
        ]),
        Line::from(vec![
            Span::styled(
                run.name.clone(),
                Style::default().add_modifier(Modifier::BOLD),
            ),
            Span::styled(
                format!(" · {} · {}", run.head_branch, run.display_title),
                Style::default().fg(Color::Gray),
            ),
        ]),
    ])
}

fn draw_details(frame: &mut Frame<'_>, app: &App, area: Rect) {
    let block = Block::default()
        .title(" RUN DETAILS ")
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::Blue));

    let Some(run) = app.selected_run() else {
        frame.render_widget(
            Paragraph::new("No GitHub Actions runs found for this repository.").block(block),
            area,
        );
        return;
    };

    let lines = vec![
        detail_line("Workflow", &run.name),
        detail_line("Title", &run.display_title),
        detail_line("Run", &format!("#{} · {}", run.id, run.status)),
        detail_line("Branch", &run.head_branch),
        detail_line("Event", &run.event),
        detail_line("Created", &run.created_at),
        detail_line(
            "Started",
            run.started_at.as_deref().unwrap_or("not started"),
        ),
        detail_line("Updated", &run.updated_at),
        detail_line(
            "Conclusion",
            run.conclusion.as_deref().unwrap_or("not finished"),
        ),
        detail_line("URL", &run.url),
        Line::from(""),
        Line::from(Span::styled(
            "Press Enter to open this run in the browser.",
            Style::default().fg(Color::Green),
        )),
    ];
    frame.render_widget(
        Paragraph::new(lines).block(block).wrap(Wrap { trim: true }),
        area,
    );
}

fn detail_line(label: &str, value: &str) -> Line<'static> {
    Line::from(vec![
        Span::styled(format!("{label:<10} "), Style::default().fg(Color::Gray)),
        Span::raw(value.to_owned()),
    ])
}

fn draw_help(frame: &mut Frame<'_>, app: &App, area: Rect) {
    let message = app
        .message
        .as_deref()
        .map(|message| format!("  {message}"))
        .unwrap_or_default();
    let line = Line::from(vec![
        Span::styled(" j/k ", Style::default().fg(Color::Black).bg(Color::Cyan)),
        Span::styled(" move  ", Style::default().fg(Color::Gray)),
        Span::styled(
            " enter ",
            Style::default().fg(Color::Black).bg(Color::Green),
        ),
        Span::styled(" browser  ", Style::default().fg(Color::Gray)),
        Span::styled(" r ", Style::default().fg(Color::Black).bg(Color::Yellow)),
        Span::styled(" refresh  ", Style::default().fg(Color::Gray)),
        Span::styled(" q ", Style::default().fg(Color::Black).bg(Color::Red)),
        Span::styled(" quit", Style::default().fg(Color::Gray)),
        Span::styled(message, Style::default().fg(Color::Yellow)),
    ]);
    frame.render_widget(Paragraph::new(line), area);
}

fn status_color(status: &str, conclusion: Option<&str>) -> Color {
    match (status, conclusion) {
        ("in_progress", _) => Color::Yellow,
        ("queued", _) => Color::Cyan,
        ("completed", Some("success")) => Color::Green,
        ("completed", Some("failure" | "timed_out" | "startup_failure")) => Color::Red,
        ("completed", Some("cancelled")) => Color::DarkGray,
        _ => Color::Gray,
    }
}

#[cfg(test)]
mod tests {
    use super::Run;

    #[test]
    fn parses_github_run_json() {
        let runs: Vec<Run> = serde_json::from_str(
            r#"[
                {
                    "databaseId": 42,
                    "name": "CI",
                    "displayTitle": "Add feature",
                    "headBranch": "main",
                    "status": "in_progress",
                    "conclusion": null,
                    "event": "push",
                    "createdAt": "2026-01-01T10:00:00Z",
                    "startedAt": "2026-01-01T10:01:00Z",
                    "updatedAt": "2026-01-01T10:02:00Z",
                    "url": "https://github.com/example/repo/actions/runs/42"
                }
            ]"#,
        )
        .expect("valid gh run JSON");

        assert_eq!(runs[0].id, 42);
        assert_eq!(runs[0].name, "CI");
        assert_eq!(runs[0].started_at.as_deref(), Some("2026-01-01T10:01:00Z"));

        let mut older = runs[0].clone();
        older.id = 41;
        older.created_at = "2025-12-31T10:00:00Z".to_owned();
        let mut ordered = vec![older, runs[0].clone()];
        super::sort_latest(&mut ordered);
        assert_eq!(ordered[0].id, 42);
    }
}
