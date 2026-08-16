mod collector;
mod git;
mod model;
mod process;
mod state;
mod tmux;
mod ui;

use anyhow::Result;
use clap::{Parser, Subcommand};
use std::collections::HashMap;

#[derive(Parser)]
#[command(version, about)]
struct Cli {
    #[command(subcommand)]
    command: Option<Command>,
}

#[derive(Subcommand)]
enum Command {
    /// Open the full agent dashboard.
    Dashboard,
    /// Open the compact dashboard for a tmux side pane.
    Sidebar,
    /// Print the current agent registry without opening a TUI.
    Snapshot {
        /// Print machine-readable JSON.
        #[arg(long)]
        json: bool,
    },
}

fn main() -> Result<()> {
    match Cli::parse().command.unwrap_or(Command::Dashboard) {
        Command::Dashboard => ui::run(ui::View::Dashboard),
        Command::Sidebar => ui::run(ui::View::Sidebar),
        Command::Snapshot { json } => snapshot(json),
    }
}

fn snapshot(json: bool) -> Result<()> {
    let agents = collector::collect(&mut HashMap::new())?;
    if json {
        println!("{}", serde_json::to_string_pretty(&agents)?);
        return Ok(());
    }
    if agents.is_empty() {
        println!("No supported agents found in tmux.");
        return Ok(());
    }
    for agent in agents {
        println!(
            "{:?}\t{}\t{}\t{}\t{}",
            agent.status,
            agent.kind,
            agent.pane.location(),
            agent.project_name(),
            agent.task.as_deref().unwrap_or("")
        );
    }
    Ok(())
}
