use crate::model::RepoInfo;
use std::process::Command;

pub fn inspect(path: &str) -> Result<RepoInfo, String> {
    let mut info = RepoInfo::default();
    let status = Command::new("git")
        .args(["-C", path, "status", "--porcelain=v1", "--branch"])
        .output()
        .map_err(|error| format!("git status failed: {error}"))?;
    if !status.status.success() {
        return Err("git status returned a failure".to_owned());
    }

    let output = String::from_utf8_lossy(&status.stdout);
    let mut lines = output.lines();
    if let Some(header) = lines.next().and_then(|line| line.strip_prefix("## ")) {
        let branch = header
            .split_once("...")
            .map_or(header, |(branch, _)| branch)
            .trim();
        if !branch.is_empty() && branch != "HEAD (no branch)" {
            info.branch = Some(branch.to_owned());
        }
    }
    info.changed_files = lines.count();

    let diff = Command::new("git")
        .args(["-C", path, "diff", "--numstat", "HEAD", "--"])
        .output()
        .map_err(|error| format!("git diff failed: {error}"))?;
    if !diff.status.success() {
        return Err("git diff returned a failure".to_owned());
    }
    for line in String::from_utf8_lossy(&diff.stdout).lines() {
        let mut fields = line.split_whitespace();
        info.additions += fields
            .next()
            .and_then(|value| value.parse().ok())
            .unwrap_or(0);
        info.deletions += fields
            .next()
            .and_then(|value| value.parse().ok())
            .unwrap_or(0);
    }
    Ok(info)
}
