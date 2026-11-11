//! Options from the Lua side, passed as one JSON argument. Unknown keys are an error.

use crate::input::Modifier;
use serde::Deserialize;
use std::collections::HashSet;

#[derive(Deserialize, Debug)]
#[serde(default, deny_unknown_fields)]
pub struct Config {
    /// Letters used for labels, in priority order.
    pub alphabet: String,
    /// Built-in pattern names. `None` means the default set.
    pub patterns: Option<Vec<String>>,
    /// Extra regexes. A `(?P<match>...)` group limits what is copied.
    pub extra: Vec<String>,
    /// ":copy:", ":paste:", ":open:", "" (copy only) or a shell command that reads the match on stdin.
    pub main_action: String,
    pub shift_action: String,
    pub ctrl_action: String,
    pub alt_action: String,
    /// SGR parameters, e.g. "1;38;5;0;48;5;12".
    pub hint_style: String,
    pub highlight_style: String,
    /// Dim the text that is not a match. Off by default: the capture is shown as it was.
    pub dim: bool,
    /// Rows of history to capture above the screen. Page Up and Page Down scroll through them.
    pub scrollback: usize,
    /// "left" or "right": which end of a match gets its hint.
    pub hint_position: String,
}

impl Default for Config {
    fn default() -> Self {
        Config {
            alphabet: "asdfghjklwertyuiopzxvbnm".into(),
            patterns: None,
            extra: Vec::new(),
            main_action: ":copy:".into(),
            shift_action: ":paste:".into(),
            ctrl_action: ":open:".into(),
            alt_action: String::new(),
            hint_style: "1;38;5;0;48;5;12".into(),
            highlight_style: "1;38;5;12".into(),
            dim: false,
            scrollback: 2000,
            hint_position: "left".into(),
        }
    }
}

/// A larger capture would make every key press slow.
const MAX_SCROLLBACK: usize = 50_000;

fn sgr_ok(s: &str) -> bool {
    s.bytes().all(|b| b.is_ascii_digit() || b == b';' || b == b':')
}

impl Config {
    /// The defaults when there is no JSON.
    pub fn from_optional_json(json: Option<&str>) -> Result<Config, String> {
        json.map_or_else(|| Ok(Config::default()), Config::from_json)
    }

    pub fn from_json(json: &str) -> Result<Config, String> {
        let cfg: Config = serde_json::from_str(json).map_err(|e| format!("config: {e}"))?;
        cfg.validate()?;
        Ok(cfg)
    }

    fn validate(&self) -> Result<(), String> {
        if self.hint_position != "left" && self.hint_position != "right" {
            return Err(format!(
                "config: hint_position must be \"left\" or \"right\", got {:?}",
                self.hint_position
            ));
        }
        let letters: HashSet<char> = self.alphabet.chars().collect();
        if letters.len() < 2
            || letters.len() != self.alphabet.chars().count()
            || !self.alphabet.chars().all(|c| c.is_ascii_lowercase())
        {
            return Err("config: alphabet needs at least 2 distinct letters a-z".into());
        }
        if self.scrollback > MAX_SCROLLBACK {
            return Err(format!("config: scrollback must be at most {MAX_SCROLLBACK} rows"));
        }
        if !sgr_ok(&self.hint_style) || !sgr_ok(&self.highlight_style) {
            return Err("config: styles may only hold digits, ';' and ':'".into());
        }
        Ok(())
    }

    pub fn alphabet_chars(&self) -> Vec<char> {
        self.alphabet.chars().collect()
    }

    pub fn action(&self, m: Modifier) -> &str {
        match m {
            Modifier::Main => &self.main_action,
            Modifier::Shift => &self.shift_action,
            Modifier::Ctrl => &self.ctrl_action,
            Modifier::Alt => &self.alt_action,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_object_gives_the_defaults() {
        let c = Config::from_json("{}").unwrap();
        assert_eq!(c.main_action, ":copy:");
        assert_eq!(c.shift_action, ":paste:");
    }

    #[test]
    fn unknown_key_is_an_error() {
        assert!(Config::from_json(r#"{"colour":"red"}"#).is_err());
    }

    #[test]
    fn style_with_a_letter_is_an_error() {
        assert!(Config::from_json(r#"{"hint_style":"1;31m"}"#).is_err());
    }

    #[test]
    fn repeated_letter_in_alphabet_is_an_error() {
        assert!(Config::from_json(r#"{"alphabet":"aab"}"#).is_err());
    }

    #[test]
    fn overlay_option_is_gone() {
        assert!(Config::from_json(r#"{"overlay":"pane"}"#).is_err());
    }

    #[test]
    fn scrollback_has_a_default_and_a_limit() {
        assert_eq!(Config::from_json("{}").unwrap().scrollback, 2000);
        assert_eq!(Config::from_json(r#"{"scrollback":0}"#).unwrap().scrollback, 0);
        assert!(Config::from_json(r#"{"scrollback":50001}"#).is_err());
    }

    #[test]
    fn unknown_hint_position_is_an_error() {
        assert!(Config::from_json(r#"{"hint_position":"middle"}"#).is_err());
    }
}
