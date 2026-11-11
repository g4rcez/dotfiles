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

/// Moves the view through the captured history.
#[derive(Clone, Copy)]
pub enum Scroll {
    LineUp,
    LineDown,
    PageUp,
    PageDown,
    Top,
    Bottom,
}

pub enum Key {
    /// The terminal changed size: draw again.
    Redraw,
    Scroll(Scroll),
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
            KeyCode::Up => return Ok(Key::Scroll(Scroll::LineUp)),
            KeyCode::Down => return Ok(Key::Scroll(Scroll::LineDown)),
            KeyCode::PageUp => return Ok(Key::Scroll(Scroll::PageUp)),
            KeyCode::PageDown => return Ok(Key::Scroll(Scroll::PageDown)),
            KeyCode::Home => return Ok(Key::Scroll(Scroll::Top)),
            KeyCode::End => return Ok(Key::Scroll(Scroll::Bottom)),
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
