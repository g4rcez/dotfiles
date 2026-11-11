//! Calls to the `rex` CLI. Arguments always go as an argv list; no shell is involved.

use serde_json::{Value, json};
use std::ffi::OsString;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::OnceLock;

/// Where the Rex app keeps its command line tool on macOS.
const APP_BIN_DIR: &str = "Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS";

fn is_executable(path: &Path) -> bool {
    path.metadata().is_ok_and(|m| m.is_file() && m.permissions().mode() & 0o111 != 0)
}

/// Finds the `rex` command. A process that Rex starts from Lua can have a short PATH without it, so
/// look in this order: REX_BIN, PATH, REX_BIN_DIR (which Rex exports), the app bundle in HOME.
/// When nothing is found it returns plain "rex" and the OS reports the error.
fn resolve(
    rex_bin: Option<OsString>,
    path: Option<OsString>,
    bin_dir: Option<OsString>,
    home: Option<OsString>,
) -> PathBuf {
    if let Some(explicit) = rex_bin {
        return PathBuf::from(explicit);
    }
    let mut dirs: Vec<PathBuf> = path.iter().flat_map(std::env::split_paths).collect();
    dirs.extend(bin_dir.map(PathBuf::from));
    dirs.extend(home.map(|h| PathBuf::from(h).join(APP_BIN_DIR)));
    dirs.into_iter()
        .map(|d| d.join("rex"))
        .find(|c| is_executable(c))
        .unwrap_or_else(|| PathBuf::from("rex"))
}

fn rex_command() -> Command {
    static REX: OnceLock<PathBuf> = OnceLock::new();
    let bin = REX.get_or_init(|| {
        let var = std::env::var_os;
        resolve(var("REX_BIN"), var("PATH"), var("REX_BIN_DIR"), var("HOME"))
    });
    Command::new(bin)
}

pub struct Target {
    pub session: String,
    pub block: String,
}

pub struct Size {
    pub columns: usize,
    pub rows: usize,
}

/// `what` names the call in an error message. The arguments stay out of it, because they can hold screen text.
fn run(what: &str, args: &[&str]) -> Result<String, String> {
    let out = rex_command()
        .args(args)
        .output()
        .map_err(|e| format!("rex {what}: {e}"))?;
    if !out.status.success() {
        let err = String::from_utf8_lossy(&out.stderr);
        return Err(format!("rex {what}: {}", err.trim()));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

impl Target {
    /// The screen and scrollback of the pane, with colours. Wrapped rows are joined, so a newline
    /// always ends a line that the program wrote.
    pub fn capture_vt(&self) -> Result<String, String> {
        run(
            "capture",
            &["capture", "-s", &self.session, "-b", &self.block, "--format", "vt", "--unwrap"],
        )
    }

    pub fn size(&self) -> Result<Size, String> {
        let out = run("size", &["block", "call", "-s", &self.session, "-b", &self.block, "size"])?;
        let v: Value = serde_json::from_str(&out).map_err(|e| format!("rex size: {e}"))?;
        let field = |name: &str| {
            v[name]
                .as_u64()
                .map(|n| n as usize)
                .ok_or_else(|| format!("rex size: no {name} in reply"))
        };
        Ok(Size { columns: field("columns")?, rows: field("rows")? })
    }

    /// Types `data` into the pane as if the user had typed it.
    pub fn write(&self, data: &str) -> Result<(), String> {
        let args = json!({ "data": data }).to_string();
        run(
            "write",
            &["block", "call", "-s", &self.session, "-b", &self.block, "write", &args],
        )
        .map(|_| ())
    }

    pub fn focus(&self) {
        // Best effort: the layer closes either way.
        let _ = run("focus", &["focus", "-s", &self.session, &self.block]);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    /// A new empty directory, optionally holding an executable `rex`.
    fn dir_with_rex(name: &str, executable: bool) -> PathBuf {
        let dir = std::env::temp_dir().join(format!("rexflash-test-{}-{name}", std::process::id()));
        let _ = fs::remove_dir_all(&dir);
        fs::create_dir_all(&dir).unwrap();
        if executable {
            let rex = dir.join("rex");
            fs::write(&rex, "#!/bin/sh\n").unwrap();
            fs::set_permissions(&rex, fs::Permissions::from_mode(0o755)).unwrap();
        }
        dir
    }

    #[test]
    fn explicit_rex_bin_wins() {
        let on_path = dir_with_rex("explicit", true);
        let got = resolve(Some("/opt/my/rex".into()), Some(on_path.into()), None, None);
        assert_eq!(got, PathBuf::from("/opt/my/rex"));
    }

    #[test]
    fn rex_on_the_path_is_found() {
        let empty = dir_with_rex("path-empty", false);
        let with_rex = dir_with_rex("path-rex", true);
        let path = std::env::join_paths([empty, with_rex.clone()]).unwrap();
        assert_eq!(resolve(None, Some(path), None, None), with_rex.join("rex"));
    }

    #[test]
    fn rex_bin_dir_is_used_when_path_has_no_rex() {
        let empty = dir_with_rex("bindir-empty", false);
        let with_rex = dir_with_rex("bindir-rex", true);
        let got = resolve(None, Some(empty.into()), Some(with_rex.clone().into()), None);
        assert_eq!(got, with_rex.join("rex"));
    }

    #[test]
    fn app_bundle_under_home_is_the_last_place() {
        let home = dir_with_rex("home", false);
        let bundle = home.join(APP_BIN_DIR);
        fs::create_dir_all(&bundle).unwrap();
        fs::write(bundle.join("rex"), "#!/bin/sh\n").unwrap();
        fs::set_permissions(bundle.join("rex"), fs::Permissions::from_mode(0o755)).unwrap();
        assert_eq!(resolve(None, None, None, Some(home.into())), bundle.join("rex"));
    }

    #[test]
    fn a_file_that_is_not_executable_is_skipped() {
        let dir = dir_with_rex("not-exec", true);
        fs::set_permissions(dir.join("rex"), fs::Permissions::from_mode(0o644)).unwrap();
        assert_eq!(resolve(None, Some(dir.into()), None, None), PathBuf::from("rex"));
    }

    #[test]
    fn nothing_found_falls_back_to_plain_rex() {
        assert_eq!(resolve(None, None, None, None), PathBuf::from("rex"));
    }
}
