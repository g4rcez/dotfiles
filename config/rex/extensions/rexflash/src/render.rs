//! Draws the captured screen with hints and highlights. Everything that is not marked is dimmed.

use crate::screen::Screen;
use crossterm::{cursor::MoveTo, queue, style::Print, terminal::{Clear, ClearType}};
use std::collections::{HashMap, HashSet};
use std::io::{self, Write};

#[derive(Default)]
pub struct Marks {
    /// Cells of a match, as (row, column) in the screen.
    pub highlight: HashSet<(usize, usize)>,
    /// Cells that show a label character instead of the text.
    pub labels: HashMap<(usize, usize), char>,
}

pub struct Style {
    hint: String,
    highlight: String,
    dim: bool,
}

impl Style {
    pub fn new(hint: &str, highlight: &str, dim: bool) -> Style {
        Style { hint: format!("\x1b[{hint}m"), highlight: format!("\x1b[{highlight}m"), dim }
    }
}

/// Draws `rows` rows of `screen`, from row `top`, at the top-left corner. Text beyond `cols` columns is cut.
/// Marks use the row numbers of the whole screen.
pub fn draw(
    out: &mut impl Write,
    screen: &Screen,
    marks: &Marks,
    style: &Style,
    cols: usize,
    top: usize,
    rows: usize,
) -> io::Result<()> {
    for (r, row) in screen.rows.iter().enumerate().skip(top).take(rows) {
        let mut line = String::new();
        // (kind, original style); kind 0 = plain, 1 = highlight, 2 = label.
        let mut state: Option<(u8, u32)> = None;
        for (c, cell) in row.iter().enumerate().take(cols) {
            if cell.width == 0 {
                continue;
            }
            let (kind, ch) = match marks.labels.get(&(r, c)) {
                Some(&l) => (2, l),
                None if marks.highlight.contains(&(r, c)) => (1, cell.ch),
                None => (0, cell.ch),
            };
            let key = (kind, if kind == 0 { cell.style } else { 0 });
            if state != Some(key) {
                line.push_str("\x1b[0m");
                match kind {
                    2 => line.push_str(&style.hint),
                    1 => line.push_str(&style.highlight),
                    _ => {
                        line.push_str(&screen.styles[cell.style as usize]);
                        if style.dim {
                            line.push_str("\x1b[2m");
                        }
                    }
                }
                state = Some(key);
            }
            line.push(ch);
            if kind == 2 && cell.width == 2 {
                line.push(' ');
            }
        }
        line.push_str("\x1b[0m");
        // Clear first: after a full-width row the cursor waits on the last column, and clearing then would erase it.
        queue!(out, MoveTo(0, (r - top) as u16), Clear(ClearType::CurrentLine), Print(&line))?;
    }
    out.flush()
}
