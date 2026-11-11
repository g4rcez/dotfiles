//! The hint and flash overlays as state machines, and the float overlay loop.
//!
//! An overlay turns a key into a `Step` and describes what to draw (`Marks`). The float loop below
//! and the pane daemon in `pane.rs` both drive the same state machines.

use crate::actions;
use crate::config::Config;
use crate::flash;
use crate::hints;
use crate::input::{self, Key, Modifier};
use crate::patterns::{self, Found, Pattern};
use crate::render::{self, Marks, Style};
use crate::rex::Target;
use crate::screen::{Line, Screen};
use crossterm::{
    cursor::{Hide, Show},
    execute, queue,
    terminal::{self, Clear, ClearType, EnterAlternateScreen, LeaveAlternateScreen},
};
use std::collections::HashMap;
use std::io::{self, BufWriter};

#[derive(Clone, Copy)]
pub enum Mode {
    Hint,
    Flash,
}

pub struct Picked {
    pub text: String,
    pub modifier: Modifier,
    pub hint: String,
}

pub enum Step {
    Continue,
    Pick(Picked),
    Cancel,
}

pub trait Overlay {
    fn marks(&self) -> Marks;
    fn step(&mut self, key: Key) -> Step;
}

/// The captured screen and everything found in it.
pub struct Loaded {
    pub screen: Screen,
    pub lines: Vec<Line>,
    pub found: Vec<Found>,
}

/// The last `n` lines of `s`, for `n` >= 1. Lines end with '\n'.
fn tail_lines(s: &str, n: usize) -> &str {
    s.rmatch_indices('\n').nth(n).map_or(s, |(i, _)| &s[i + 1..])
}

fn lower(c: char) -> char {
    c.to_lowercase().next().unwrap_or(c)
}

impl Loaded {
    /// `cols` and `rows` are the size of the captured pane.
    pub fn new(vt: &str, cols: usize, rows: usize, patterns: &[Pattern]) -> Loaded {
        let screen = Screen::parse(tail_lines(vt, rows + 1), cols).tail(rows);
        let lines = screen.lines();
        let found = patterns::find_all(patterns, &lines);
        Loaded { screen, lines, found }
    }
}

pub fn overlay<'a>(mode: Mode, loaded: &'a Loaded, cfg: &Config) -> Box<dyn Overlay + 'a> {
    let alphabet = cfg.alphabet_chars();
    match mode {
        Mode::Hint => Box::new(Hint::new(loaded, alphabet, cfg.hint_position == "right")),
        Mode::Flash => Box::new(Flash { loaded, alphabet, query: String::new() }),
    }
}

pub fn style(cfg: &Config, dim: bool) -> Style {
    Style::new(&cfg.hint_style, &cfg.highlight_style, dim)
}

struct Hint<'a> {
    loaded: &'a Loaded,
    alphabet: Vec<char>,
    right: bool,
    /// One text per distinct match text, most important first.
    texts: Vec<&'a str>,
    /// The text group of each entry of `loaded.found`.
    group_of: Vec<usize>,
    /// `labels[g]` is the label of text group `g`. Groups past the last label have none.
    labels: Vec<String>,
    typed: String,
}

impl<'a> Hint<'a> {
    fn new(loaded: &'a Loaded, alphabet: Vec<char>, right: bool) -> Self {
        // Same text, same label. The most important texts come first and get the shortest labels.
        let found = &loaded.found;
        let mut order: Vec<usize> = (0..found.len()).collect();
        order.sort_by(|&a, &b| {
            found[b]
                .weight
                .cmp(&found[a].weight)
                .then(found[a].line.cmp(&found[b].line))
                .then(found[a].start.cmp(&found[b].start))
        });
        let mut texts: Vec<&str> = Vec::new();
        let mut index: HashMap<&str, usize> = HashMap::new();
        let mut group_of = vec![0; found.len()];
        for &i in &order {
            let text = found[i].text.as_str();
            group_of[i] = *index.entry(text).or_insert_with(|| {
                texts.push(text);
                texts.len() - 1
            });
        }
        let labels = hints::assign(texts.len(), &alphabet);
        Hint { loaded, alphabet, right, texts, group_of, labels, typed: String::new() }
    }
}

impl Overlay for Hint<'_> {
    fn marks(&self) -> Marks {
        let mut marks = Marks::default();
        for (i, f) in self.loaded.found.iter().enumerate() {
            let Some(label) = self.labels.get(self.group_of[i]) else {
                continue;
            };
            if !label.starts_with(&self.typed) {
                continue;
            }
            let pos = &self.loaded.lines[f.line].pos;
            for &cell in &pos[f.start..f.end] {
                marks.highlight.insert(cell);
            }
            let rest: Vec<char> = label.chars().skip(self.typed.chars().count()).collect();
            if rest.len() <= f.end - f.start {
                let first = if self.right { f.end - rest.len() } else { f.start };
                for (k, ch) in rest.into_iter().enumerate() {
                    marks.labels.insert(pos[first + k], ch);
                }
            }
        }
        marks
    }

    fn step(&mut self, key: Key) -> Step {
        match key {
            Key::Cancel => Step::Cancel,
            Key::Backspace => {
                self.typed.pop();
                Step::Continue
            }
            Key::Enter | Key::Redraw => Step::Continue,
            Key::Char(c, modifier) => {
                let c = lower(c);
                if !self.alphabet.contains(&c) {
                    return if c == 'q' { Step::Cancel } else { Step::Continue };
                }
                let mut next = self.typed.clone();
                next.push(c);
                if let Some(g) = self.labels.iter().position(|l| *l == next) {
                    return Step::Pick(Picked { text: self.texts[g].to_string(), modifier, hint: next });
                }
                // A prefix that matches no label starts over.
                self.typed = if self.labels.iter().any(|l| l.starts_with(&next)) { next } else { String::new() };
                Step::Continue
            }
        }
    }
}

struct Flash<'a> {
    loaded: &'a Loaded,
    alphabet: Vec<char>,
    query: String,
}

impl Flash<'_> {
    fn hits(&self) -> (Vec<flash::Hit>, Vec<Option<char>>) {
        let mut hits = flash::search(&self.loaded.lines, &self.query);
        flash::sort_bottom_first(&mut hits, &self.loaded.lines);
        let labels = flash::labels(&hits, &self.loaded.lines, &self.alphabet);
        (hits, labels)
    }
}

/// Where a flash label goes: over the character after the match, else over the last character of it.
fn flash_label_cell(line: &Line, h: &flash::Hit) -> (usize, usize) {
    let last = line.pos[h.end - 1];
    match line.pos.get(h.end) {
        Some(&next) if next.0 == last.0 => next,
        _ => last,
    }
}

impl Overlay for Flash<'_> {
    fn marks(&self) -> Marks {
        let (hits, labels) = self.hits();
        let mut marks = Marks::default();
        for (h, label) in hits.iter().zip(&labels) {
            let line = &self.loaded.lines[h.line];
            for &cell in &line.pos[h.start..h.end] {
                marks.highlight.insert(cell);
            }
            if let Some(ch) = label {
                marks.labels.insert(flash_label_cell(line, h), *ch);
            }
        }
        marks
    }

    fn step(&mut self, key: Key) -> Step {
        let (hits, labels) = self.hits();
        let pick = |i: usize, modifier: Modifier| {
            let hint = labels[i].map(String::from).unwrap_or_default();
            let text = flash::pick_text(&self.loaded.lines, &self.loaded.found, &hits[i]);
            Step::Pick(Picked { text, modifier, hint })
        };
        match key {
            Key::Cancel => Step::Cancel,
            Key::Backspace => {
                self.query.pop();
                Step::Continue
            }
            Key::Enter if hits.len() == 1 => pick(0, Modifier::Main),
            Key::Enter | Key::Redraw => Step::Continue,
            Key::Char(c, modifier) => {
                if let Some(i) = labels.iter().position(|l| *l == Some(lower(c))) {
                    return pick(i, modifier);
                }
                if modifier == Modifier::Main || modifier == Modifier::Shift {
                    self.query.push(c);
                }
                Step::Continue
            }
        }
    }
}

/// Raw mode and the alternate screen, undone when it is dropped.
struct Guard;

impl Guard {
    fn enter() -> io::Result<Guard> {
        terminal::enable_raw_mode()?;
        let guard = Guard;
        execute!(io::stdout(), EnterAlternateScreen, Hide)?;
        Ok(guard)
    }
}

impl Drop for Guard {
    fn drop(&mut self) {
        let _ = execute!(io::stdout(), Show, LeaveAlternateScreen);
        let _ = terminal::disable_raw_mode();
    }
}

fn io_err(e: io::Error) -> String {
    format!("terminal: {e}")
}

/// Runs the action of a pick: copy first, then paste, open or the configured command.
pub fn perform(cfg: &Config, picked: &Picked, target: &Target, cwd: Option<&str>) -> Result<(), String> {
    actions::perform(cfg.action(picked.modifier), &picked.text, picked.modifier, &picked.hint, target, cwd)
}

/// The float overlay: this process owns a terminal that covers the pane.
pub fn run(mode: Mode, target: &Target, cfg: &Config, cwd: Option<&str>) -> Result<(), String> {
    let patterns = patterns::build(cfg.patterns.as_deref(), &cfg.extra)?;
    let size = target.size()?;
    let vt = target.capture_vt()?;
    let loaded = Loaded::new(&vt, size.columns, size.rows, &patterns);
    let mut overlay = overlay(mode, &loaded, cfg);
    let style = style(cfg, cfg.dim);

    let picked = {
        let _guard = Guard::enter().map_err(io_err)?;
        let mut out = BufWriter::new(io::stdout());
        queue!(out, Clear(ClearType::All)).map_err(io_err)?;
        loop {
            // The size is read for every frame. Rex resizes a new float a moment after it starts.
            let (cols, rows) = terminal::size().map_err(io_err)?;
            render::draw(&mut out, &loaded.screen, &overlay.marks(), &style, cols as usize, rows as usize)
                .map_err(io_err)?;
            let key = input::read().map_err(io_err)?;
            if let Key::Redraw = key {
                queue!(out, Clear(ClearType::All)).map_err(io_err)?;
                continue;
            }
            match overlay.step(key) {
                Step::Continue => {}
                Step::Pick(p) => break Some(p),
                Step::Cancel => break None,
            }
        }
    };

    match picked {
        Some(p) => perform(cfg, &p, target, cwd),
        None => Ok(()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn loaded(vt: &str) -> Loaded {
        Loaded::new(vt, 80, 3, &patterns::build(None, &[]).unwrap())
    }

    fn cfg(json: &str) -> Config {
        Config::from_json(json).unwrap()
    }

    fn pick(step: Step) -> (String, Modifier, String) {
        match step {
            Step::Pick(p) => (p.text, p.modifier, p.hint),
            _ => panic!("expected a pick"),
        }
    }

    #[test]
    fn tail_lines_keeps_whole_lines() {
        assert_eq!(tail_lines("a\nb\nc\n", 2), "b\nc\n");
    }

    #[test]
    fn tail_lines_of_short_text_is_all_of_it() {
        assert_eq!(tail_lines("a\nb\n", 5), "a\nb\n");
    }

    #[test]
    fn hint_label_picks_the_match() {
        let l = loaded("see https://example.com/a ok\n\n\n");
        let mut o = overlay(Mode::Hint, &l, &cfg("{}"));
        assert_eq!(
            pick(o.step(Key::Char('a', Modifier::Main))),
            ("https://example.com/a".into(), Modifier::Main, "a".into())
        );
    }

    #[test]
    fn hint_uppercase_label_is_a_shift_pick() {
        let l = loaded("see https://example.com/a ok\n\n\n");
        let mut o = overlay(Mode::Hint, &l, &cfg("{}"));
        assert_eq!(pick(o.step(Key::Char('A', Modifier::Shift))).1, Modifier::Shift);
    }

    // Alphabet "abc" and 6 matches give the labels a, ba, bb, bc, ca, cb.
    const SIX_PATHS: &str = "a/b1 c/d2 e/f3 g/h4 i/j5 k/l6\n\n\n";

    #[test]
    fn hint_two_letter_label_needs_both_keys() {
        let l = loaded(SIX_PATHS);
        let mut o = overlay(Mode::Hint, &l, &cfg(r#"{"alphabet":"abc"}"#));
        assert!(matches!(o.step(Key::Char('b', Modifier::Main)), Step::Continue));
        assert_eq!(pick(o.step(Key::Char('a', Modifier::Main))), ("c/d2".into(), Modifier::Main, "ba".into()));
    }

    #[test]
    fn hint_q_and_escape_cancel() {
        let l = loaded("x\n\n\n");
        let mut o = overlay(Mode::Hint, &l, &cfg("{}"));
        assert!(matches!(o.step(Key::Char('q', Modifier::Main)), Step::Cancel));
        assert!(matches!(o.step(Key::Cancel), Step::Cancel));
    }

    #[test]
    fn hint_hides_labels_that_do_not_start_with_the_typed_prefix() {
        let l = loaded(SIX_PATHS);
        let mut o = overlay(Mode::Hint, &l, &cfg(r#"{"alphabet":"abc"}"#));
        let before = o.marks().labels.len();
        o.step(Key::Char('b', Modifier::Main));
        // Before: 1 cell for "a" and 2 cells for each of the 5 other labels. After "b": the last letter of ba, bb, bc.
        assert_eq!((before, o.marks().labels.len()), (11, 3));
    }

    #[test]
    fn flash_query_then_label_picks_the_whole_match() {
        let l = loaded("open https://example.com/a now\n\n\n");
        let mut o = overlay(Mode::Flash, &l, &cfg("{}"));
        for c in "exa".chars() {
            assert!(matches!(o.step(Key::Char(c, Modifier::Main)), Step::Continue));
        }
        assert_eq!(
            pick(o.step(Key::Char('a', Modifier::Main))),
            ("https://example.com/a".into(), Modifier::Main, "a".into())
        );
    }

    #[test]
    fn flash_label_never_equals_the_next_character() {
        // "exa" is followed by 'm', so typing 'm' extends the query instead of picking.
        let l = loaded("open https://example.com/a now\n\n\n");
        let mut o = overlay(Mode::Flash, &l, &cfg("{}"));
        for c in "exa".chars() {
            o.step(Key::Char(c, Modifier::Main));
        }
        assert!(matches!(o.step(Key::Char('m', Modifier::Main)), Step::Continue));
        assert_eq!(o.marks().highlight.len(), 4);
    }

    #[test]
    fn flash_enter_picks_only_a_single_hit() {
        let l = loaded("one two\n\n\n");
        let mut o = overlay(Mode::Flash, &l, &cfg("{}"));
        o.step(Key::Char('o', Modifier::Main));
        assert!(matches!(o.step(Key::Enter), Step::Continue));
        o.step(Key::Char('n', Modifier::Main));
        assert_eq!(pick(o.step(Key::Enter)).0, "one");
    }
}
