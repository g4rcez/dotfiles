//! The hint and flash overlays as state machines, and the float overlay loop.
//!
//! The pane is captured once: its screen and some scrollback. The overlay shows `rows` rows of that
//! capture, from row `top`, and only the matches in those rows get labels. Page Up, Page Down, the
//! arrow keys, Home and End move `top`.

use crate::actions;
use crate::config::Config;
use crate::flash;
use crate::hints;
use crate::input::{self, Key, Modifier, Scroll};
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
    /// The rows on display: `rows` rows from row `top` of the screen. Only matches there get labels.
    fn set_view(&mut self, top: usize, rows: usize);
    fn marks(&self) -> Marks;
    fn step(&mut self, key: Key) -> Step;
}

/// The captured screen with its scrollback, and everything found in it.
pub struct Loaded {
    pub screen: Screen,
    pub lines: Vec<Line>,
    pub found: Vec<Found>,
    /// The first row of the live screen. The overlay starts there.
    pub live_top: usize,
}

/// The last `n` lines of `s`, for `n` >= 1. Lines end with '\n'.
fn tail_lines(s: &str, n: usize) -> &str {
    s.rmatch_indices('\n').nth(n).map_or(s, |(i, _)| &s[i + 1..])
}

fn lower(c: char) -> char {
    c.to_lowercase().next().unwrap_or(c)
}

impl Loaded {
    /// `cols` and `pane_rows` are the size of the captured pane. Up to `scrollback` rows above its screen are kept.
    pub fn new(vt: &str, cols: usize, pane_rows: usize, scrollback: usize, patterns: &[Pattern]) -> Loaded {
        let keep = pane_rows + scrollback;
        let screen = Screen::parse(tail_lines(vt, keep + 1), cols).tail(keep);
        let live_top = screen.rows.len().saturating_sub(pane_rows);
        let lines = screen.lines();
        let found = patterns::find_all(patterns, &lines);
        Loaded { screen, lines, found, live_top }
    }

    /// Whether the character at `index` of line `line` is on display.
    fn in_view(&self, line: usize, index: usize, top: usize, rows: usize) -> bool {
        let row = self.lines[line].pos[index].0;
        row >= top && row < top + rows
    }
}

/// The new first row of the view after a scroll key. The view never goes past the captured rows.
pub fn scrolled(top: usize, total: usize, rows: usize, scroll: Scroll) -> usize {
    let max = total.saturating_sub(rows);
    let new = match scroll {
        Scroll::LineUp => top.saturating_sub(1),
        Scroll::LineDown => top + 1,
        Scroll::PageUp => top.saturating_sub(rows),
        Scroll::PageDown => top + rows,
        Scroll::Top => 0,
        Scroll::Bottom => max,
    };
    new.min(max)
}

pub fn overlay<'a>(mode: Mode, loaded: &'a Loaded, cfg: &Config) -> Box<dyn Overlay + 'a> {
    let alphabet = cfg.alphabet_chars();
    match mode {
        Mode::Hint => Box::new(Hint::new(loaded, alphabet, cfg.hint_position == "right")),
        Mode::Flash => Box::new(Flash { loaded, alphabet, query: String::new(), view: (0, usize::MAX) }),
    }
}

pub fn style(cfg: &Config, dim: bool) -> Style {
    Style::new(&cfg.hint_style, &cfg.highlight_style, dim)
}

struct Hint<'a> {
    loaded: &'a Loaded,
    alphabet: Vec<char>,
    right: bool,
    /// (top, rows) of the view.
    view: (usize, usize),
    /// One text per distinct match text in view, most important first.
    texts: Vec<&'a str>,
    /// The text group of each entry of `loaded.found`. `None` when the match is not in view.
    group_of: Vec<Option<usize>>,
    /// `labels[g]` is the label of text group `g`. Groups past the last label have none.
    labels: Vec<String>,
    typed: String,
}

impl<'a> Hint<'a> {
    fn new(loaded: &'a Loaded, alphabet: Vec<char>, right: bool) -> Self {
        let mut hint = Hint {
            loaded,
            alphabet,
            right,
            view: (0, usize::MAX),
            texts: Vec::new(),
            group_of: Vec::new(),
            labels: Vec::new(),
            typed: String::new(),
        };
        hint.rebuild();
        hint
    }

    /// Same text, same label. The most important texts come first and get the shortest labels.
    fn rebuild(&mut self) {
        let loaded: &'a Loaded = self.loaded;
        let (top, rows) = self.view;
        let found = &loaded.found;
        let mut order: Vec<usize> = (0..found.len())
            .filter(|&i| loaded.in_view(found[i].line, found[i].start, top, rows))
            .collect();
        order.sort_by(|&a, &b| {
            found[b]
                .weight
                .cmp(&found[a].weight)
                .then(found[a].line.cmp(&found[b].line))
                .then(found[a].start.cmp(&found[b].start))
        });
        let mut texts: Vec<&'a str> = Vec::new();
        let mut index: HashMap<&str, usize> = HashMap::new();
        let mut group_of = vec![None; found.len()];
        for &i in &order {
            let text = found[i].text.as_str();
            group_of[i] = Some(*index.entry(text).or_insert_with(|| {
                texts.push(text);
                texts.len() - 1
            }));
        }
        self.labels = hints::assign(texts.len(), &self.alphabet);
        self.texts = texts;
        self.group_of = group_of;
        self.typed.clear();
    }
}

impl Overlay for Hint<'_> {
    fn set_view(&mut self, top: usize, rows: usize) {
        if self.view != (top, rows) {
            self.view = (top, rows);
            self.rebuild();
        }
    }

    fn marks(&self) -> Marks {
        let mut marks = Marks::default();
        for (i, f) in self.loaded.found.iter().enumerate() {
            let Some(label) = self.group_of[i].and_then(|g| self.labels.get(g)) else {
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
            Key::Enter | Key::Redraw | Key::Scroll(_) => Step::Continue,
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
    /// (top, rows) of the view.
    view: (usize, usize),
}

impl Flash<'_> {
    /// The matches of the query that are in view, and their labels.
    fn hits(&self) -> (Vec<flash::Hit>, Vec<Option<char>>) {
        let (top, rows) = self.view;
        let mut hits = flash::search(&self.loaded.lines, &self.query);
        hits.retain(|h| self.loaded.in_view(h.line, h.start, top, rows));
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
    fn set_view(&mut self, top: usize, rows: usize) {
        self.view = (top, rows);
    }

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
            Key::Enter | Key::Redraw | Key::Scroll(_) => Step::Continue,
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
    let loaded = Loaded::new(&vt, size.columns, size.rows, cfg.scrollback, &patterns);
    let total = loaded.screen.rows.len();
    let mut overlay = overlay(mode, &loaded, cfg);
    let style = style(cfg, cfg.dim);
    let mut top = loaded.live_top;

    let picked = {
        let _guard = Guard::enter().map_err(io_err)?;
        let mut out = BufWriter::new(io::stdout());
        queue!(out, Clear(ClearType::All)).map_err(io_err)?;
        loop {
            // The size is read for every frame. Rex resizes a new float a moment after it starts.
            let (cols, rows) = terminal::size().map_err(io_err)?;
            let (cols, rows) = (cols as usize, rows as usize);
            top = top.min(total.saturating_sub(rows));
            overlay.set_view(top, rows);
            render::draw(&mut out, &loaded.screen, &overlay.marks(), &style, cols, top, rows).map_err(io_err)?;
            match input::read().map_err(io_err)? {
                Key::Redraw => {
                    queue!(out, Clear(ClearType::All)).map_err(io_err)?;
                }
                Key::Scroll(s) => top = scrolled(top, total, rows, s),
                key => match overlay.step(key) {
                    Step::Continue => {}
                    Step::Pick(p) => break Some(p),
                    Step::Cancel => break None,
                },
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
        Loaded::new(vt, 80, 3, 0, &patterns::build(None, &[]).unwrap())
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

    // Five rows, one path each. A pane of 2 rows leaves 3 rows of scrollback.
    const FIVE_ROWS: &str = "p/a1\np/b2\np/c3\np/d4\np/e5\n";

    fn with_scrollback() -> Loaded {
        Loaded::new(FIVE_ROWS, 80, 2, 10, &patterns::build(None, &[]).unwrap())
    }

    #[test]
    fn the_live_screen_is_the_last_pane_rows() {
        assert_eq!(with_scrollback().live_top, 3);
    }

    #[test]
    fn scrollback_is_limited_to_the_configured_rows() {
        let l = Loaded::new(FIVE_ROWS, 80, 2, 1, &patterns::build(None, &[]).unwrap());
        assert_eq!((l.screen.rows.len(), l.live_top), (3, 1));
    }

    #[test]
    fn hint_labels_only_the_matches_in_view() {
        let l = with_scrollback();
        let mut o = overlay(Mode::Hint, &l, &cfg("{}"));
        o.set_view(3, 2);
        let rows: std::collections::BTreeSet<usize> = o.marks().labels.keys().map(|c| c.0).collect();
        assert_eq!(rows, [3, 4].into());
        o.set_view(0, 2);
        let rows: std::collections::BTreeSet<usize> = o.marks().labels.keys().map(|c| c.0).collect();
        assert_eq!(rows, [0, 1].into());
    }

    #[test]
    fn hint_labels_restart_when_the_view_changes() {
        let l = with_scrollback();
        let mut o = overlay(Mode::Hint, &l, &cfg("{}"));
        o.set_view(3, 2);
        // "p/d4" is the first match in view, so it has the first label.
        assert_eq!(pick(o.step(Key::Char('a', Modifier::Main))).0, "p/d4");
        o.set_view(0, 2);
        assert_eq!(pick(o.step(Key::Char('a', Modifier::Main))).0, "p/a1");
    }

    #[test]
    fn flash_finds_only_the_matches_in_view() {
        let l = with_scrollback();
        let mut o = overlay(Mode::Flash, &l, &cfg("{}"));
        o.set_view(3, 2);
        o.step(Key::Char('p', Modifier::Main));
        assert_eq!(o.marks().highlight.len(), 2);
        o.set_view(0, 5);
        assert_eq!(o.marks().highlight.len(), 5);
    }

    #[test]
    fn scrolling_moves_the_view_and_stops_at_the_ends() {
        // 10 captured rows, 4 rows on display: top can be 0..=6.
        assert_eq!(scrolled(3, 10, 4, Scroll::LineUp), 2);
        assert_eq!(scrolled(3, 10, 4, Scroll::LineDown), 4);
        assert_eq!(scrolled(3, 10, 4, Scroll::PageUp), 0);
        assert_eq!(scrolled(3, 10, 4, Scroll::PageDown), 6);
        assert_eq!(scrolled(3, 10, 4, Scroll::Top), 0);
        assert_eq!(scrolled(3, 10, 4, Scroll::Bottom), 6);
        assert_eq!(scrolled(0, 10, 4, Scroll::LineUp), 0);
        assert_eq!(scrolled(6, 10, 4, Scroll::LineDown), 6);
    }

    #[test]
    fn scrolling_a_short_capture_stays_at_the_top() {
        assert_eq!(scrolled(0, 3, 10, Scroll::PageDown), 0);
    }
}
