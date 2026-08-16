use crate::model::AgentKind;
use anyhow::{Context, Result};
use std::collections::{HashMap, VecDeque};
use std::process::Command;

#[derive(Clone, Debug)]
pub struct ProcessRow {
    pid: u32,
    ppid: u32,
    command: String,
}

pub fn snapshot() -> Result<Vec<ProcessRow>> {
    let output = Command::new("ps")
        .args(["-A", "-o", "pid=,ppid=,args="])
        .output()
        .context("failed to inspect processes")?;
    if !output.status.success() {
        anyhow::bail!("ps exited with {}", output.status);
    }
    Ok(parse_snapshot(&String::from_utf8_lossy(&output.stdout)))
}

fn parse_snapshot(output: &str) -> Vec<ProcessRow> {
    output.lines().filter_map(parse_row).collect()
}

fn parse_row(line: &str) -> Option<ProcessRow> {
    let mut fields = line.split_whitespace();
    let pid = fields.next()?.parse().ok()?;
    let ppid = fields.next()?.parse().ok()?;
    let command = fields.collect::<Vec<_>>().join(" ");
    Some(ProcessRow { pid, ppid, command })
}

pub fn contains_pid(rows: &[ProcessRow], pid: u32) -> bool {
    rows.iter().any(|row| row.pid == pid)
}

pub fn is_descendant(root_pid: u32, target_pid: u32, rows: &[ProcessRow]) -> bool {
    let parents: HashMap<u32, u32> = rows.iter().map(|row| (row.pid, row.ppid)).collect();
    let mut current = target_pid;
    for _ in 0..32 {
        if current == root_pid {
            return true;
        }
        let Some(parent) = parents.get(&current) else {
            return false;
        };
        if *parent == current {
            return false;
        }
        current = *parent;
    }
    false
}

pub fn detect_for_pane(root_pid: u32, rows: &[ProcessRow]) -> Option<AgentKind> {
    let by_pid: HashMap<u32, &ProcessRow> = rows.iter().map(|row| (row.pid, row)).collect();
    let mut children: HashMap<u32, Vec<u32>> = HashMap::new();
    for row in rows {
        children.entry(row.ppid).or_default().push(row.pid);
    }

    let mut queue = VecDeque::from([(root_pid, 0_u8)]);
    while let Some((pid, depth)) = queue.pop_front() {
        if let Some(row) = by_pid.get(&pid)
            && let Some(kind) = detect_command(&row.command)
        {
            return Some(kind);
        }
        if depth >= 6 {
            continue;
        }
        if let Some(child_pids) = children.get(&pid) {
            queue.extend(child_pids.iter().map(|child| (*child, depth + 1)));
        }
    }
    None
}

fn detect_command(command: &str) -> Option<AgentKind> {
    let tokens: Vec<&str> = command.split_whitespace().take(6).collect();
    let executable = tokens.first()?;
    let basename = executable.rsplit('/').next().unwrap_or(executable);
    if basename == "env" {
        return detect_command(&tokens.iter().skip(1).copied().collect::<Vec<_>>().join(" "));
    }
    if let Some(kind) = detect_basename(basename) {
        return Some(kind);
    }

    let script = if matches!(basename, "node" | "bun" | "deno") {
        tokens.iter().skip(1).find(|token| !token.starts_with('-'))
    } else {
        None
    };
    if let Some(script) = script
        && let Some(kind) = detect_basename(script.rsplit('/').next().unwrap_or(script))
    {
        return Some(kind);
    }

    let lower = script.unwrap_or(executable).to_ascii_lowercase();
    if lower.contains("/@anthropic-ai/claude-code/") {
        Some(AgentKind::Claude)
    } else if lower.contains("/@openai/codex/") {
        Some(AgentKind::Codex)
    } else if lower.contains("/@google/gemini-cli/") {
        Some(AgentKind::Gemini)
    } else if lower.contains("/opencode-ai/") {
        Some(AgentKind::Opencode)
    } else if lower.contains("/pi-coding-agent/") {
        Some(AgentKind::Pi)
    } else {
        None
    }
}

fn detect_basename(basename: &str) -> Option<AgentKind> {
    match basename {
        "claude" | "claude-code" => Some(AgentKind::Claude),
        "codex" => Some(AgentKind::Codex),
        "gemini" | "gemini-cli" => Some(AgentKind::Gemini),
        "opencode" => Some(AgentKind::Opencode),
        "pi" => Some(AgentKind::Pi),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn detects_node_wrapped_agent_in_descendants() {
        let rows = parse_snapshot(
            "100 1 /bin/zsh\n101 100 node /opt/homebrew/lib/node_modules/@openai/codex/bin/codex\n",
        );
        assert_eq!(detect_for_pane(100, &rows), Some(AgentKind::Codex));
    }

    #[test]
    fn ignores_agent_name_in_later_arguments() {
        assert_eq!(detect_command("rg pi src"), None);
        assert_eq!(detect_command("node app.js codex"), None);
        assert_eq!(detect_command("node /work/opencode/server.js"), None);
    }

    #[test]
    fn verifies_process_membership_in_pane_tree() {
        let rows = parse_snapshot("100 1 /bin/zsh\n101 100 node pi\n200 1 node pi\n");
        assert!(is_descendant(100, 101, &rows));
        assert!(!is_descendant(100, 200, &rows));
    }

    #[test]
    fn detects_bun_wrapped_pi() {
        assert_eq!(
            detect_command("bun /opt/pi-coding-agent/dist/cli.js"),
            Some(AgentKind::Pi)
        );
    }
}
