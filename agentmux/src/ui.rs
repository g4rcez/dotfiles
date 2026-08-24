use crate::collector;
use crate::git;
use crate::model::{AgentRecord, AgentStatus, RepoInfo, TmuxPane};
use crate::tmux;
use anyhow::Result;
use crossterm::event::{self, Event, KeyCode, KeyEventKind};
use crossterm::execute;
use crossterm::terminal::{
    disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen,
};
use ratatui::backend::CrosstermBackend;
use ratatui::layout::{Constraint, Direction, Layout, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Wrap};
use ratatui::Terminal;
use std::collections::HashMap;
use std::io::{self, Stdout};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

const BLUE: Color = Color::Rgb(122, 162, 247);
const CYAN: Color = Color::Rgb(125, 207, 255);
const GREEN: Color = Color::Rgb(158, 206, 106);
const YELLOW: Color = Color::Rgb(224, 175, 104);
const RED: Color = Color::Rgb(247, 118, 142);
const MUTED: Color = Color::Rgb(86, 95, 137);
const BG: Color = Color::Rgb(26, 27, 38);
const SELECTED: Color = Color::Rgb(41, 46, 66);

#[derive(Clone, Copy, Eq, PartialEq)]
pub enum View {
    Dashboard,
    Sidebar,
}

struct App {
    view: View,
    agents: Vec<AgentRecord>,
    selected: usize,
    preview: String,
    current_session: Option<String>,
    session_only: bool,
    repo_cache: HashMap<String, RepoInfo>,
    last_agent_refresh: Instant,
    last_git_refresh: Instant,
    last_preview_refresh: Instant,
    git_pending: bool,
}

impl App {
    fn new(view: View) -> Result<Self> {
        let mut repo_cache = HashMap::new();
        let agents = collector::collect(&mut repo_cache)?;
        let now = Instant::now();
        let mut app = Self {
            view,
            agents,
            selected: 0,
            preview: String::new(),
            current_session: tmux::current_session(),
            session_only: false,
            repo_cache,
            last_agent_refresh: now,
            last_git_refresh: now,
            last_preview_refresh: now,
            git_pending: view == View::Dashboard,
        };
        app.refresh_preview();
        Ok(app)
    }

    fn visible_agents(&self) -> Vec<&AgentRecord> {
        self.agents
            .iter()
            .filter(|agent| {
                !self.session_only
                    || self
                        .current_session
                        .as_deref()
                        .is_some_and(|session| agent.pane.session_name == session)
            })
            .collect()
    }

    fn selected_agent(&self) -> Option<&AgentRecord> {
        self.visible_agents().get(self.selected).copied()
    }

    fn ensure_selection(&mut self) {
        let count = self.visible_agents().len();
        if count == 0 {
            self.selected = 0;
        } else if self.selected >= count {
            self.selected = count - 1;
        }
    }

    fn refresh_agents(&mut self) {
        let selected_pane = self
            .selected_agent()
            .map(|agent| agent.pane.pane_id.clone());
        if let Ok(agents) = collector::collect(&mut self.repo_cache) {
            self.agents = agents;
            if let Some(pane_id) = selected_pane {
                self.selected = self
                    .visible_agents()
                    .iter()
                    .position(|agent| agent.pane.pane_id == pane_id)
                    .unwrap_or(self.selected);
            }
            self.ensure_selection();
        }
        self.last_agent_refresh = Instant::now();
    }

    fn refresh_selected_repo(&mut self) {
        if self.view != View::Dashboard {
            return;
        }
        if let Some(path) = self.selected_agent().map(|agent| agent.pane.path.clone()) {
            let repo = git::inspect(&path);
            self.repo_cache.insert(path.clone(), repo.clone());
            for agent in self
                .agents
                .iter_mut()
                .filter(|agent| agent.pane.path == path)
            {
                agent.repo = repo.clone();
            }
        }
        self.last_git_refresh = Instant::now();
        self.git_pending = false;
    }

    fn refresh_preview(&mut self) {
        if self.view == View::Dashboard {
            self.preview = self
                .selected_agent()
                .map(|agent| tmux::capture_pane(&agent.pane.pane_id))
                .unwrap_or_else(|| "No agent selected".to_owned());
        }
        self.last_preview_refresh = Instant::now();
    }

    fn selection_changed(&mut self) {
        self.git_pending = self.view == View::Dashboard;
        self.last_git_refresh = Instant::now();
        self.refresh_preview();
    }

    fn move_next(&mut self) {
        let count = self.visible_agents().len();
        if count > 0 {
            self.selected = (self.selected + 1).min(count - 1);
            self.selection_changed();
        }
    }

    fn move_previous(&mut self) {
        self.selected = self.selected.saturating_sub(1);
        self.selection_changed();
    }
}

struct TerminalGuard;

impl Drop for TerminalGuard {
    fn drop(&mut self) {
        let _ = disable_raw_mode();
        let _ = execute!(io::stdout(), LeaveAlternateScreen, crossterm::cursor::Show);
    }
}

pub fn run(view: View) -> Result<()> {
    enable_raw_mode()?;
    let result = {
        let _guard = TerminalGuard;
        let mut stdout = io::stdout();
        execute!(stdout, EnterAlternateScreen, crossterm::cursor::Hide)?;
        let backend = CrosstermBackend::new(stdout);
        let mut terminal = Terminal::new(backend)?;
        terminal.clear()?;
        run_loop(&mut terminal, view)
    };

    if let Some(pane) = result? {
        tmux::jump_to(&pane)?;
    }
    Ok(())
}

fn run_loop(
    terminal: &mut Terminal<CrosstermBackend<Stdout>>,
    view: View,
) -> Result<Option<TmuxPane>> {
    let mut app = App::new(view)?;
    let mut dirty = true;

    loop {
        if app.last_agent_refresh.elapsed() >= Duration::from_secs(2) {
            app.refresh_agents();
            dirty = true;
        }
        if view == View::Dashboard
            && app.last_preview_refresh.elapsed() >= Duration::from_millis(500)
        {
            app.refresh_preview();
            dirty = true;
        }
        if !app.git_pending && app.last_git_refresh.elapsed() >= Duration::from_secs(10) {
            app.git_pending = view == View::Dashboard;
        }
        if dirty {
            terminal.draw(|frame| draw(frame, &app))?;
            dirty = false;
        }
        if app.git_pending && app.last_git_refresh.elapsed() >= Duration::from_millis(200) {
            app.refresh_selected_repo();
            dirty = true;
            continue;
        }

        if !event::poll(Duration::from_millis(200))? {
            continue;
        }
        let Event::Key(key) = event::read()? else {
            dirty = true;
            continue;
        };
        if key.kind != KeyEventKind::Press {
            continue;
        }
        match key.code {
            KeyCode::Char('q') | KeyCode::Esc => return Ok(None),
            KeyCode::Char('j') | KeyCode::Down => app.move_next(),
            KeyCode::Char('k') | KeyCode::Up => app.move_previous(),
            KeyCode::Char('g') | KeyCode::Home => {
                app.selected = 0;
                app.selection_changed();
            }
            KeyCode::Char('G') | KeyCode::End => {
                app.selected = app.visible_agents().len().saturating_sub(1);
                app.selection_changed();
            }
            KeyCode::Char('f') => {
                app.session_only = !app.session_only;
                app.selected = 0;
                app.selection_changed();
            }
            KeyCode::Enter | KeyCode::Char('l') => {
                return Ok(app.selected_agent().map(|agent| agent.pane.clone()));
            }
            _ => continue,
        }
        dirty = true;
    }
}

fn draw(frame: &mut ratatui::Frame<'_>, app: &App) {
    match app.view {
        View::Dashboard => draw_dashboard(frame, app),
        View::Sidebar => draw_sidebar(frame, app),
    }
}

fn draw_dashboard(frame: &mut ratatui::Frame<'_>, app: &App) {
    let area = frame.area();
    let rows = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Min(3), Constraint::Length(1)])
        .split(area);
    let columns = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(38), Constraint::Percentage(62)])
        .split(rows[0]);

    draw_agent_list(frame, app, columns[0], false);
    let title = app
        .selected_agent()
        .map(|agent| format!(" {} · {} ", agent.project_name(), agent.pane.location()))
        .unwrap_or_else(|| " Preview ".to_owned());
    let preview = Paragraph::new(app.preview.as_str())
        .block(
            Block::default()
                .title(title)
                .borders(Borders::ALL)
                .border_style(Style::default().fg(BLUE)),
        )
        .style(Style::default().fg(Color::White).bg(BG))
        .wrap(Wrap { trim: false });
    frame.render_widget(preview, columns[1]);
    draw_help(frame, app, rows[1]);
}

fn draw_sidebar(frame: &mut ratatui::Frame<'_>, app: &App) {
    let area = frame.area();
    let rows = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Min(3), Constraint::Length(1)])
        .split(area);
    draw_agent_list(frame, app, rows[0], true);
    draw_help(frame, app, rows[1]);
}

fn draw_agent_list(frame: &mut ratatui::Frame<'_>, app: &App, area: Rect, compact: bool) {
    let visible = app.visible_agents();
    let items: Vec<ListItem<'_>> = visible
        .iter()
        .map(|agent| agent_item(agent, compact))
        .collect();
    let filter = if app.session_only { "session" } else { "all" };
    let title = format!(" AGENTS {} · {filter} ", visible.len());
    let list = List::new(items)
        .block(
            Block::default()
                .title(title)
                .borders(Borders::ALL)
                .border_style(Style::default().fg(CYAN)),
        )
        .highlight_style(
            Style::default()
                .fg(Color::White)
                .bg(SELECTED)
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("› ");
    let mut state = ListState::default();
    if !visible.is_empty() {
        state.select(Some(app.selected));
    }
    frame.render_stateful_widget(list, area, &mut state);
}

fn agent_item<'a>(agent: &'a AgentRecord, compact: bool) -> ListItem<'a> {
    let (icon, color, label) = status_display(agent.status);
    let elapsed = agent
        .status_since_ms
        .map(elapsed_since)
        .unwrap_or_else(|| "detected".to_owned());
    let branch = agent.repo.branch.as_deref().unwrap_or("no git");
    let git_stats = if agent.repo.additions > 0 || agent.repo.deletions > 0 {
        format!(" +{} -{}", agent.repo.additions, agent.repo.deletions)
    } else if agent.repo.changed_files > 0 {
        format!(" ~{}", agent.repo.changed_files)
    } else {
        String::new()
    };

    let mut lines = vec![Line::from(vec![
        Span::styled(format!("{icon} "), Style::default().fg(color)),
        Span::styled(
            agent.project_name(),
            Style::default().add_modifier(Modifier::BOLD),
        ),
        Span::raw("  "),
        Span::styled(elapsed, Style::default().fg(MUTED)),
    ])];
    lines.push(Line::from(vec![
        Span::styled(agent.kind.to_string(), Style::default().fg(CYAN)),
        Span::styled(
            format!(" · {} · {branch}", agent.pane.location()),
            Style::default().fg(MUTED),
        ),
        Span::styled(git_stats, Style::default().fg(GREEN)),
    ]));
    if !compact {
        lines.push(Line::from(Span::styled(
            agent.task.as_deref().unwrap_or(label),
            Style::default().fg(Color::White),
        )));
    } else if let Some(task) = agent.task.as_deref() {
        lines.push(Line::from(Span::styled(task, Style::default().fg(MUTED))));
    }
    ListItem::new(lines)
}

fn draw_help(frame: &mut ratatui::Frame<'_>, app: &App, area: Rect) {
    let filter = if app.session_only {
        "session"
    } else {
        "all sessions"
    };
    let help = Paragraph::new(Line::from(vec![
        Span::styled(" j/k ", Style::default().fg(BG).bg(BLUE)),
        Span::styled(" move  ", Style::default().fg(MUTED)),
        Span::styled(" enter ", Style::default().fg(BG).bg(GREEN)),
        Span::styled(" jump  ", Style::default().fg(MUTED)),
        Span::styled(" f ", Style::default().fg(BG).bg(YELLOW)),
        Span::styled(format!(" {filter}  "), Style::default().fg(MUTED)),
        Span::styled(" q ", Style::default().fg(BG).bg(RED)),
        Span::styled(" close ", Style::default().fg(MUTED)),
    ]))
    .style(Style::default().bg(BG));
    frame.render_widget(help, area);
}

fn status_display(status: AgentStatus) -> (&'static str, Color, &'static str) {
    match status {
        AgentStatus::Working => ("◐", YELLOW, "Agent is working"),
        AgentStatus::Waiting => ("●", CYAN, "Agent is waiting"),
        AgentStatus::Done => ("✓", GREEN, "Agent finished"),
        AgentStatus::Unknown => ("○", MUTED, "No lifecycle integration"),
    }
}

fn elapsed_since(timestamp_ms: u64) -> String {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis() as u64;
    let seconds = now.saturating_sub(timestamp_ms) / 1_000;
    if seconds < 60 {
        format!("{seconds}s")
    } else if seconds < 3_600 {
        format!("{}m", seconds / 60)
    } else {
        format!("{}h", seconds / 3_600)
    }
}
