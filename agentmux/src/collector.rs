use crate::model::{AgentRecord, AgentStatus, RepoInfo};
use crate::{process, state, tmux};
use anyhow::Result;
use std::collections::HashMap;

pub fn collect(repo_cache: &mut HashMap<String, RepoInfo>) -> Result<Vec<AgentRecord>> {
    let panes = tmux::list_panes()?;
    let processes = process::snapshot()?;
    let states: HashMap<_, _> = state::load()
        .unwrap_or_default()
        .into_iter()
        .filter_map(|agent| {
            if process::contains_pid(&processes, agent.pid) {
                Some((agent.pane_id.clone(), agent))
            } else {
                state::remove(&agent.pane_id);
                None
            }
        })
        .collect();

    let mut records = Vec::new();
    for pane in panes.into_iter().filter(|pane| !pane.is_sidebar) {
        let tracked = states
            .get(&pane.pane_id)
            .filter(|agent| process::is_descendant(pane.pid, agent.pid, &processes));
        if states.contains_key(&pane.pane_id) && tracked.is_none() {
            state::remove(&pane.pane_id);
        }
        let kind = tracked
            .map(|agent| agent.agent)
            .or_else(|| process::detect_for_pane(pane.pid, &processes));
        let Some(kind) = kind else {
            continue;
        };

        let repo = repo_cache.get(&pane.path).cloned().unwrap_or_default();
        records.push(AgentRecord {
            pane,
            kind,
            status: tracked.map_or(AgentStatus::Unknown, |agent| agent.status),
            task: tracked.and_then(|agent| agent.task.clone()),
            status_since_ms: tracked.map(|agent| agent.updated_at_ms),
            repo,
        });
    }

    records.sort_by(|left, right| {
        status_rank(left.status)
            .cmp(&status_rank(right.status))
            .then_with(|| left.pane.session_name.cmp(&right.pane.session_name))
            .then_with(|| left.pane.window_index.cmp(&right.pane.window_index))
            .then_with(|| left.pane.pane_index.cmp(&right.pane.pane_index))
    });
    Ok(records)
}

fn status_rank(status: AgentStatus) -> u8 {
    match status {
        AgentStatus::Done => 0,
        AgentStatus::Waiting => 1,
        AgentStatus::Working => 2,
        AgentStatus::Unknown => 3,
    }
}
