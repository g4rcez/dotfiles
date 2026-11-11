//! Keys from the terminal.

use crossterm::event::{self, Event, KeyCode, KeyEventKind, KeyModifiers};
use std::io;

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Modifier {
    Main,
    Shift,
    Ctrl,
    Alt,
}

impl Modifier {
    pub fn name(self) -> &'static str {
        match self {
            Modifier::Main => "main",
            Modifier::Shift => "shift",
            Modifier::Ctrl => "ctrl",
            Modifier::Alt => "alt",
        }
    }
}

pub enum Key {
    /// The terminal changed size: draw again.
    Redraw,
    Cancel,
    Backspace,
    Enter,
    /// The character as typed (an uppercase letter stays uppercase) and the modifier that came with it.
    Char(char, Modifier),
}

/// Blocks until a key that rexflash uses arrives.
pub fn read() -> io::Result<Key> {
    loop {
        let k = match event::read()? {
            Event::Key(k) => k,
            Event::Resize(..) => return Ok(Key::Redraw),
            _ => continue,
        };
        if k.kind == KeyEventKind::Release {
            continue;
        }
        let ctrl = k.modifiers.contains(KeyModifiers::CONTROL);
        match k.code {
            KeyCode::Esc => return Ok(Key::Cancel),
            KeyCode::Backspace => return Ok(Key::Backspace),
            KeyCode::Enter => return Ok(Key::Enter),
            KeyCode::Char('c') if ctrl => return Ok(Key::Cancel),
            KeyCode::Char(c) => {
                let modifier = if ctrl {
                    Modifier::Ctrl
                } else if k.modifiers.contains(KeyModifiers::ALT) {
                    Modifier::Alt
                } else if c.is_uppercase() || k.modifiers.contains(KeyModifiers::SHIFT) {
                    Modifier::Shift
                } else {
                    Modifier::Main
                };
                return Ok(Key::Char(c, modifier));
            }
            _ => {}
        }
    }
}
