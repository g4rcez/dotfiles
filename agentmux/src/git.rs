use crate::model::RepoInfo;
use std::process::Command;

pub fn inspect(path: &str) -> RepoInfo {
    let mut info = RepoInfo::default();
    let status = Command::new("git")
        .args(["-C", path, "status", "--porcelain=v1", "--branch"])
        .output();
    let Ok(status) = status else {
        return info;
    };
    if !status.status.success() {
        return info;
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
        .output();
    if let Ok(diff) = diff
        && diff.status.success()
    {
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
    }
    info
}
