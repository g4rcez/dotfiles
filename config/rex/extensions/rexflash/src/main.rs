//! rexflash: capture the text of a Rex pane, show it with labels, then copy, paste or open what you pick.
//!
//! Usage: rexflash <hint|flash> --session S --block B [--cwd DIR] [--config JSON]
//!
//! The pane is captured once and shown in this terminal. The pane itself is never drawn on.

mod actions;
mod app;
mod config;
mod flash;
mod hints;
mod input;
mod patterns;
mod render;
mod rex;
mod screen;

use app::Mode;
use config::Config;
use rex::Target;

const USAGE: &str = "usage: rexflash <hint|flash> --session S --block B [--cwd DIR] [--config JSON]";

struct Args {
    mode: Mode,
    target: Target,
    cwd: Option<String>,
    /// JSON text, parsed when the overlay starts so that a bad config shows in the overlay.
    config: Option<String>,
}

fn parse_args() -> Result<Args, String> {
    let mut args = std::env::args().skip(1);
    let mode = match args.next().as_deref() {
        Some("hint") => Mode::Hint,
        Some("flash") => Mode::Flash,
        _ => return Err(USAGE.into()),
    };
    let (mut session, mut block, mut cwd, mut config) = (None, None, None, None);
    while let Some(flag) = args.next() {
        let value = args.next().ok_or_else(|| format!("{flag} needs a value"))?;
        match flag.as_str() {
            "--session" => session = Some(value),
            "--block" => block = Some(value),
            "--cwd" => cwd = Some(value),
            "--config" => config = Some(value),
            _ => return Err(format!("unknown option {flag}\n{USAGE}")),
        }
    }
    Ok(Args {
        mode,
        target: Target {
            session: session.ok_or("--session is required")?,
            block: block.ok_or("--block is required")?,
        },
        cwd,
        config,
    })
}

/// A failure shows in the overlay until a key is pressed; otherwise Rex would close it at once.
fn show_error(message: &str) {
    eprintln!("rexflash: {message}\n\npress any key");
    if crossterm::terminal::enable_raw_mode().is_ok() {
        let _ = crossterm::event::read();
        let _ = crossterm::terminal::disable_raw_mode();
    }
}

fn main() {
    let args = match parse_args() {
        Ok(a) => a,
        Err(e) => {
            show_error(&e);
            std::process::exit(2);
        }
    };
    let result = Config::from_optional_json(args.config.as_deref())
        .and_then(|config| app::run(args.mode, &args.target, &config, args.cwd.as_deref()));
    if let Err(e) = &result {
        show_error(e);
    }
    args.target.focus();
    std::process::exit(i32::from(result.is_err()));
}
