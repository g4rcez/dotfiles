use serde::{Deserialize, Serialize};
use std::fmt;

#[derive(Clone, Copy, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum AgentKind {
    Claude,
    Codex,
    Gemini,
    Opencode,
    Pi,
}

impl fmt::Display for AgentKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Claude => "Claude",
            Self::Codex => "Codex",
            Self::Gemini => "Gemini",
            Self::Opencode => "OpenCode",
            Self::Pi => "Pi",
        };
        f.write_str(name)
    }
}

#[derive(Clone, Copy, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum AgentStatus {
    Working,
    Waiting,
    Done,
    Unknown,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct AgentState {
    pub version: u8,
    pub agent: AgentKind,
    pub status: AgentStatus,
    pub pane_id: String,
    pub pid: u32,
    pub cwd: String,
    pub task: Option<String>,
    pub session_name: Option<String>,
    pub started_at_ms: u64,
    pub updated_at_ms: u64,
}

#[derive(Clone, Debug, Serialize)]
pub struct TmuxPane {
    pub pane_id: String,
    pub session_name: String,
    pub window_index: u32,
    pub pane_index: u32,
    pub window_name: String,
    pub command: String,
    pub title: String,
    pub path: String,
    pub pid: u32,
    pub is_sidebar: bool,
}

impl TmuxPane {
    pub fn location(&self) -> String {
        format!(
            "{}:{}.{}",
            self.session_name, self.window_index, self.pane_index
        )
    }

    pub fn window_target(&self) -> String {
        format!("{}:{}", self.session_name, self.window_index)
    }
}

#[derive(Clone, Debug, Default, Serialize)]
pub struct RepoInfo {
    pub branch: Option<String>,
    pub changed_files: usize,
    pub additions: usize,
    pub deletions: usize,
}

#[derive(Clone, Debug, Serialize)]
pub struct AgentRecord {
    pub pane: TmuxPane,
    pub kind: AgentKind,
    pub status: AgentStatus,
    pub task: Option<String>,
    pub status_since_ms: Option<u64>,
    pub repo: RepoInfo,
}

impl AgentRecord {
    pub fn project_name(&self) -> &str {
        self.pane
            .path
            .trim_end_matches('/')
            .rsplit('/')
            .next()
            .filter(|value| !value.is_empty())
            .unwrap_or(&self.pane.window_name)
    }
}
