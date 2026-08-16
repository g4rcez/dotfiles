use crate::model::TmuxPane;
use anyhow::{Context, Result};
use std::process::Command;

const SEPARATOR: char = '\u{1f}';
const PANE_FORMAT: &str = "#{pane_id}\u{1f}#{session_name}\u{1f}#{window_index}\u{1f}#{pane_index}\u{1f}#{window_name}\u{1f}#{pane_current_command}\u{1f}#{pane_title}\u{1f}#{pane_current_path}\u{1f}#{pane_pid}\u{1f}#{@is_agentmux_sidebar}";

pub fn list_panes() -> Result<Vec<TmuxPane>> {
    let output = tmux_output(&["list-panes", "-a", "-F", PANE_FORMAT])?;
    Ok(output.lines().filter_map(parse_pane).collect())
}

pub fn capture_pane(pane_id: &str, lines: u16) -> String {
    tmux_output(&[
        "capture-pane",
        "-p",
        "-S",
        &format!("-{lines}"),
        "-t",
        pane_id,
    ])
    .unwrap_or_else(|_| "Preview unavailable".to_owned())
}

pub fn current_session() -> Option<String> {
    tmux_output(&["display-message", "-p", "#{session_name}"])
        .ok()
        .map(|value| value.trim().to_owned())
        .filter(|value| !value.is_empty())
}

pub fn jump_to(pane: &TmuxPane) -> Result<()> {
    tmux_status(&["switch-client", "-t", &pane.window_target()])?;
    tmux_status(&["select-pane", "-t", &pane.pane_id])
}

fn tmux_output(args: &[&str]) -> Result<String> {
    let output = Command::new("tmux")
        .args(args)
        .output()
        .with_context(|| format!("failed to run tmux {}", args.join(" ")))?;
    if !output.status.success() {
        anyhow::bail!(
            "tmux {} failed: {}",
            args.join(" "),
            String::from_utf8_lossy(&output.stderr).trim()
        );
    }
    Ok(String::from_utf8_lossy(&output.stdout).into_owned())
}

fn tmux_status(args: &[&str]) -> Result<()> {
    let status = Command::new("tmux")
        .args(args)
        .status()
        .with_context(|| format!("failed to run tmux {}", args.join(" ")))?;
    if !status.success() {
        anyhow::bail!("tmux {} exited with {status}", args.join(" "));
    }
    Ok(())
}

fn parse_pane(line: &str) -> Option<TmuxPane> {
    let fields: Vec<&str> = line.split(SEPARATOR).collect();
    if fields.len() != 10 {
        return None;
    }
    Some(TmuxPane {
        pane_id: fields[0].to_owned(),
        session_name: fields[1].to_owned(),
        window_index: fields[2].parse().ok()?,
        pane_index: fields[3].parse().ok()?,
        window_name: fields[4].to_owned(),
        command: fields[5].to_owned(),
        title: fields[6].to_owned(),
        path: fields[7].to_owned(),
        pid: fields[8].parse().ok()?,
        is_sidebar: fields[9] == "1",
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_tmux_format_without_losing_spaces() {
        let line = "%1\u{1f}main\u{1f}2\u{1f}0\u{1f}agent work\u{1f}zsh\u{1f}pi - task\u{1f}/tmp/my project\u{1f}123\u{1f}0";
        let pane = parse_pane(line).unwrap();
        assert_eq!(pane.location(), "main:2.0");
        assert_eq!(pane.path, "/tmp/my project");
        assert!(!pane.is_sidebar);
    }
}
