//! What happens after a pick. Every pick is copied first, as in tmux-fingers.
//!
//! Screen text only ever travels as stdin or as one argv element. It is never put into a shell string.
//! The only shell string is a command from the config.

use crate::input::Modifier;
use crate::rex::Target;
use std::io::Write;
use std::process::{Command, Stdio};

pub fn perform(
    action: &str,
    text: &str,
    modifier: Modifier,
    hint: &str,
    target: &Target,
    cwd: Option<&str>,
) -> Result<(), String> {
    copy(text)?;
    match action {
        "" | ":copy:" => Ok(()),
        ":paste:" => target.write(text),
        ":open:" => open(text, cwd),
        command => run_command(command, text, modifier, hint, cwd),
    }
}

fn copy(text: &str) -> Result<(), String> {
    let mut child = Command::new("pbcopy")
        .stdin(Stdio::piped())
        .spawn()
        .map_err(|e| format!("pbcopy: {e}"))?;
    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(text.as_bytes()).map_err(|e| format!("pbcopy: {e}"))?;
    }
    let status = child.wait().map_err(|e| format!("pbcopy: {e}"))?;
    if status.success() { Ok(()) } else { Err(format!("pbcopy: {status}")) }
}

/// `src/main.rs:42:5` opens `src/main.rs`. A URL keeps its port.
fn strip_line_suffix(text: &str) -> &str {
    if text.contains("://") {
        return text;
    }
    let mut s = text;
    for _ in 0..2 {
        match s.rsplit_once(':') {
            Some((head, tail))
                if !head.is_empty() && !tail.is_empty() && tail.bytes().all(|b| b.is_ascii_digit()) =>
            {
                s = head;
            }
            _ => break,
        }
    }
    s
}

/// Makes the text safe as one argument of `open`: no `~`, and never a leading dash that reads as an option.
fn open_arg(text: &str, home: Option<&str>) -> String {
    let path = strip_line_suffix(text);
    if let (Some(rest), Some(home)) = (path.strip_prefix("~/"), home) {
        return format!("{home}/{rest}");
    }
    if path.starts_with('-') {
        return format!("./{path}");
    }
    path.to_string()
}

fn open(text: &str, cwd: Option<&str>) -> Result<(), String> {
    let mut cmd = Command::new("open");
    cmd.arg(open_arg(text, std::env::var("HOME").ok().as_deref()));
    if let Some(dir) = cwd {
        cmd.current_dir(dir);
    }
    let out = cmd.output().map_err(|e| format!("open: {e}"))?;
    if out.status.success() {
        Ok(())
    } else {
        Err(format!("open: {}", String::from_utf8_lossy(&out.stderr).trim()))
    }
}

fn run_command(
    command: &str,
    text: &str,
    modifier: Modifier,
    hint: &str,
    cwd: Option<&str>,
) -> Result<(), String> {
    let mut cmd = Command::new("sh");
    cmd.arg("-c")
        .arg(command)
        .env("MODIFIER", modifier.name())
        .env("HINT", hint)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());
    if let Some(dir) = cwd {
        cmd.current_dir(dir);
    }
    let mut child = cmd.spawn().map_err(|e| format!("sh: {e}"))?;
    if let Some(mut stdin) = child.stdin.take() {
        // The command may exit without reading its input.
        let _ = stdin.write_all(text.as_bytes());
    }
    let out = child.wait_with_output().map_err(|e| format!("sh: {e}"))?;
    if out.status.success() {
        Ok(())
    } else {
        Err(format!("command failed ({}): {}", out.status, String::from_utf8_lossy(&out.stderr).trim()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn open_drops_line_and_column() {
        assert_eq!(open_arg("src/main.rs:42:5", None), "src/main.rs");
    }

    #[test]
    fn open_keeps_the_port_of_a_url() {
        assert_eq!(open_arg("http://localhost:8080", None), "http://localhost:8080");
    }

    #[test]
    fn open_expands_the_home_directory() {
        assert_eq!(open_arg("~/notes.md", Some("/Users/x")), "/Users/x/notes.md");
    }

    #[test]
    fn open_never_passes_a_leading_dash() {
        assert_eq!(open_arg("-a/Some.app", None), "./-a/Some.app");
    }

    #[test]
    fn command_reads_the_match_on_stdin_and_sees_the_modifier() {
        let out = std::env::temp_dir().join(format!("rexflash-test-{}", std::process::id()));
        let cmd = format!("{{ cat; printf ' %s %s' \"$MODIFIER\" \"$HINT\"; }} > '{}'", out.display());
        run_command(&cmd, "the match", Modifier::Shift, "as", None).unwrap();
        assert_eq!(std::fs::read_to_string(&out).unwrap(), "the match shift as");
        std::fs::remove_file(out).unwrap();
    }

    #[test]
    fn failing_command_is_an_error() {
        assert!(run_command("exit 3", "x", Modifier::Main, "a", None).is_err());
    }
}
