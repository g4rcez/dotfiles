use crate::model::AgentState;
use anyhow::{Context, Result};
use std::fs;
use std::path::PathBuf;

pub fn state_dir() -> PathBuf {
    let user = user_component(std::env::var("UID").ok(), std::env::var("USER").ok());
    state_dir_from(
        non_empty_path("AGENTMUX_STATE_DIR"),
        non_empty_path("XDG_RUNTIME_DIR"),
        std::env::temp_dir(),
        &user,
    )
}

fn non_empty_path(name: &str) -> Option<PathBuf> {
    std::env::var_os(name)
        .filter(|value| !value.is_empty())
        .map(PathBuf::from)
}

fn user_component(uid: Option<String>, user: Option<String>) -> String {
    uid.filter(|value| !value.is_empty())
        .or_else(|| user.filter(|value| !value.is_empty()))
        .unwrap_or_else(|| "user".to_owned())
}

fn state_dir_from(
    explicit: Option<PathBuf>,
    runtime: Option<PathBuf>,
    temp: PathBuf,
    user: &str,
) -> PathBuf {
    explicit
        .filter(|path| !path.as_os_str().is_empty())
        .or_else(|| {
            runtime
                .filter(|path| !path.as_os_str().is_empty())
                .map(|path| path.join("agentmux"))
        })
        .unwrap_or_else(|| temp.join(format!("agentmux-{user}")))
}

pub fn remove(pane_id: &str) {
    let filename = format!("tmux-{}.json", pane_id.trim_start_matches('%'));
    let _ = fs::remove_file(state_dir().join(filename));
}

pub fn load() -> Result<Vec<AgentState>> {
    let directory = state_dir();
    if !directory.is_dir() {
        return Ok(Vec::new());
    }

    let mut states = Vec::new();
    for entry in fs::read_dir(&directory)
        .with_context(|| format!("failed to read {}", directory.display()))?
    {
        let path = entry?.path();
        if path.extension().and_then(|value| value.to_str()) != Some("json") {
            continue;
        }
        let Ok(contents) = fs::read_to_string(&path) else {
            continue;
        };
        if let Ok(state) = serde_json::from_str(&contents) {
            states.push(state);
        }
    }
    Ok(states)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn user_name_is_used_when_uid_is_missing_or_empty() {
        assert_eq!(
            user_component(None, Some("allangarcez".to_owned())),
            "allangarcez"
        );
        assert_eq!(
            user_component(Some(String::new()), Some("allangarcez".to_owned())),
            "allangarcez"
        );
    }

    #[test]
    fn empty_directories_fall_back_to_the_temporary_directory() {
        assert_eq!(
            state_dir_from(
                Some(PathBuf::new()),
                Some(PathBuf::new()),
                PathBuf::from("/tmp"),
                "allangarcez",
            ),
            PathBuf::from("/tmp/agentmux-allangarcez")
        );
    }

    #[test]
    fn explicit_state_directory_wins() {
        assert_eq!(
            state_dir_from(
                Some(PathBuf::from("/tmp/agentmux-test")),
                Some(PathBuf::from("/run/user/1")),
                PathBuf::from("/tmp"),
                "1",
            ),
            PathBuf::from("/tmp/agentmux-test")
        );
    }

    #[test]
    fn runtime_directory_uses_a_stable_child() {
        assert_eq!(
            state_dir_from(
                None,
                Some(PathBuf::from("/run/user/1")),
                PathBuf::from("/tmp"),
                "1",
            ),
            PathBuf::from("/run/user/1/agentmux")
        );
    }
}
