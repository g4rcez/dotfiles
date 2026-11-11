//! Built-in and user patterns. A `(?P<match>...)` group limits what is highlighted and copied.
//!
//! The `regex` crate has no look-around, so a path-like pattern starts with a boundary group
//! (`B`) that is not part of the match. This also stops a path from starting with `-`.

use crate::screen::Line;
use regex::Regex;

/// Extra test on a regex match, for rules a regex cannot express.
type Check = fn(&str) -> bool;

pub struct Pattern {
    re: Regex,
    weight: u8,
    trim: bool,
    check: Option<Check>,
}

pub struct Found {
    pub line: usize,
    /// Character index of the first character.
    pub start: usize,
    /// Character index after the last character.
    pub end: usize,
    pub text: String,
    pub weight: u8,
}

pub const DEFAULT: &[&str] = &[
    "url", "file-line", "path", "sha", "ip", "ipv6", "uuid", "email", "hex", "color", "semver",
    "diff", "git-status",
];

/// What may come before a path-like match.
const B: &str = r#"(?:^|[\s"'`(\[{<=,;])"#;

fn has_digit(s: &str) -> bool {
    s.bytes().any(|b| b.is_ascii_digit())
}

fn is_sha(s: &str) -> bool {
    has_digit(s) && s.bytes().any(|b| (b'a'..=b'f').contains(&b))
}

fn is_ipv4(s: &str) -> bool {
    let host = s.split(':').next().unwrap_or(s);
    host.split('.').all(|o| o.parse::<u16>().is_ok_and(|n| n <= 255))
}

fn is_ipv6(s: &str) -> bool {
    has_digit(s) && (s.contains("::") || s.matches(':').count() == 7)
}

fn builtin(name: &str) -> Option<Pattern> {
    let plain = |body: &str| format!("(?P<match>{body})");
    let bounded = |body: &str| format!("{B}(?P<match>{body})");
    let (weight, src, trim, check): (u8, String, bool, Option<Check>) = match name {
        "url" => (
            4,
            plain(r#"(?:https?|ftp|ssh|git|file)://[^\s<>"'`)\]}]+|git@[\w.\-]+:[\w./~\-]+"#),
            true,
            None,
        ),
        "file-line" => (
            5,
            bounded(
                r"(?:~|\.{1,2})?/?(?:[\w.@+][\w.@+\-]*/)*[\w@+][\w.@+\-]*\.[A-Za-z][A-Za-z0-9]*:\d+(?::\d+)?",
            ),
            false,
            None,
        ),
        "path" => (
            4,
            bounded(
                r"(?:~|\.{1,2})?/(?:[\w.@+\-]+/?)+|[\w@+][\w.@+\-]*(?:/[\w.@+\-]+)+/?",
            ),
            true,
            None,
        ),
        "sha" => (3, plain(r"\b[0-9a-f]{7,64}\b"), false, Some(is_sha)),
        "ip" => (1, plain(r"\b(?:\d{1,3}\.){3}\d{1,3}(?::\d{1,5})?\b"), false, Some(is_ipv4)),
        "ipv6" => (
            1,
            bounded(r"(?:[0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{1,4}\b"),
            false,
            Some(is_ipv6),
        ),
        "uuid" => (
            1,
            plain(r"\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b"),
            false,
            None,
        ),
        "email" => (1, plain(r"\b[\w.+\-]+@[\w\-]+(?:\.[\w\-]+)+\b"), false, None),
        "hex" => (1, plain(r"\b0x[0-9a-fA-F]+\b"), false, None),
        "color" => (1, plain(r"#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b"), false, None),
        "semver" => (
            1,
            plain(r"\bv?\d+\.\d+\.\d+(?:-[\w.]+)?(?:\+[\w.]+)?\b"),
            false,
            None,
        ),
        "digit" => (1, plain(r"\b\d{4,}\b"), false, None),
        "diff" => (
            3,
            r"^(?:(?:---|\+\+\+) [ab]/|diff --git a/)(?P<match>\S+)".to_string(),
            false,
            None,
        ),
        "git-status" => (
            3,
            r"^\s*(?:modified|deleted|new file|renamed|copied|typechange|both modified|both added|deleted by us|deleted by them|added by us|added by them):\s+(?P<match>\S+)"
                .to_string(),
            false,
            None,
        ),
        _ => return None,
    };
    Some(Pattern { re: Regex::new(&src).expect("built-in pattern"), weight, trim, check })
}

/// `names` selects built-ins; `None` selects `DEFAULT`. `extra` are user regexes. An unknown name is an error.
pub fn build(names: Option<&[String]>, extra: &[String]) -> Result<Vec<Pattern>, String> {
    let mut out = Vec::new();
    match names {
        Some(names) => {
            for n in names {
                out.push(builtin(n).ok_or_else(|| format!("unknown pattern {n:?}"))?);
            }
        }
        None => {
            for n in DEFAULT {
                out.push(builtin(n).expect("default pattern"));
            }
        }
    }
    for e in extra {
        let re = Regex::new(e).map_err(|err| format!("extra pattern {e:?}: {err}"))?;
        out.push(Pattern { re, weight: 2, trim: false, check: None });
    }
    Ok(out)
}

/// Finds matches in every line. Inside one line, overlaps resolve to the leftmost match, then the longest.
pub fn find_all(patterns: &[Pattern], lines: &[Line]) -> Vec<Found> {
    let mut out = Vec::new();
    for (li, line) in lines.iter().enumerate() {
        let mut found: Vec<Found> = Vec::new();
        for p in patterns {
            for caps in p.re.captures_iter(&line.text) {
                let Some(m) = caps.name("match").or_else(|| caps.get(0)) else {
                    continue;
                };
                let mut text = m.as_str();
                if p.trim {
                    text = text.trim_end_matches(['.', ',', ';', ':', '!', '?']);
                }
                if text.is_empty() || p.check.is_some_and(|check| !check(text)) {
                    continue;
                }
                found.push(Found {
                    line: li,
                    start: line.char_index(m.start()),
                    end: line.char_index(m.start() + text.len()),
                    text: text.to_string(),
                    weight: p.weight,
                });
            }
        }
        found.sort_by(|a, b| a.start.cmp(&b.start).then((b.end - b.start).cmp(&(a.end - a.start))));
        let mut last = 0;
        for f in found {
            if f.start >= last {
                last = f.end;
                out.push(f);
            }
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::screen::Screen;

    fn matches(input: &str, names: Option<&[&str]>) -> Vec<String> {
        let screen = Screen::parse(input, 200);
        let lines = screen.lines();
        let names: Option<Vec<String>> = names.map(|n| n.iter().map(|s| s.to_string()).collect());
        let patterns = build(names.as_deref(), &[]).unwrap();
        find_all(&patterns, &lines).into_iter().map(|f| f.text).collect()
    }

    #[test]
    fn url_drops_trailing_punctuation() {
        assert_eq!(
            matches("see https://example.com/a?b=1, ok\n", Some(&["url"])),
            vec!["https://example.com/a?b=1"]
        );
    }

    #[test]
    fn url_wins_over_the_path_inside_it() {
        assert_eq!(matches("https://example.com/a/b\n", None), vec!["https://example.com/a/b"]);
    }

    #[test]
    fn file_line_wins_over_path() {
        assert_eq!(matches("at ./src/main.rs:42:5 now\n", None), vec!["./src/main.rs:42:5"]);
    }

    #[test]
    fn absolute_path_matches() {
        assert_eq!(matches("cd /usr/local/bin now\n", Some(&["path"])), vec!["/usr/local/bin"]);
    }

    #[test]
    fn path_never_starts_with_a_dash() {
        assert_eq!(matches("-a/Some.app\n", Some(&["path"])), Vec::<String>::new());
    }

    #[test]
    fn sha_needs_a_digit_and_a_hex_letter() {
        assert_eq!(
            matches("abc1234def deadbeef 1234567\n", Some(&["sha"])),
            vec!["abc1234def"]
        );
    }

    #[test]
    fn ipv4_keeps_the_port_and_rejects_big_octets() {
        assert_eq!(
            matches("192.168.0.1:8080 and 999.1.1.1\n", Some(&["ip"])),
            vec!["192.168.0.1:8080"]
        );
    }

    #[test]
    fn ipv6_needs_double_colon_or_eight_groups() {
        assert_eq!(matches("::1 12:34:56\n", Some(&["ipv6"])), vec!["::1"]);
    }

    #[test]
    fn uuid_email_hex_color_semver() {
        assert_eq!(
            matches(
                "123e4567-e89b-12d3-a456-426614174000 a@b.co 0xdeadBEEF #1a2b3c v1.2.3-rc.1\n",
                Some(&["uuid", "email", "hex", "color", "semver"])
            ),
            vec![
                "123e4567-e89b-12d3-a456-426614174000",
                "a@b.co",
                "0xdeadBEEF",
                "#1a2b3c",
                "v1.2.3-rc.1"
            ]
        );
    }

    #[test]
    fn git_status_and_diff_copy_only_the_path() {
        assert_eq!(
            matches("\tmodified:   src/lib.rs\n+++ b/src/new.rs\n", Some(&["git-status", "diff"])),
            vec!["src/lib.rs", "src/new.rs"]
        );
    }

    #[test]
    fn digit_is_off_by_default() {
        assert_eq!(matches("pid 123456\n", None), Vec::<String>::new());
        assert_eq!(matches("pid 123456\n", Some(&["digit"])), vec!["123456"]);
    }

    #[test]
    fn match_on_a_wrapped_line_is_one_match() {
        let screen = Screen::parse("see https://example.com/x\n", 16);
        let lines = screen.lines();
        let found = find_all(&build(Some(&["url".to_string()]), &[]).unwrap(), &lines);
        assert_eq!(found[0].text, "https://example.com/x");
        assert_eq!(lines[0].pos[found[0].end - 1], (1, 8));
    }

    #[test]
    fn unknown_pattern_is_an_error() {
        let err = build(Some(&["kubernetes".to_string()]), &[]).err().unwrap();
        assert_eq!(err, "unknown pattern \"kubernetes\"");
    }

    #[test]
    fn extra_pattern_uses_the_match_group() {
        let screen = Screen::parse("ticket ABC-123 done\n", 80);
        let lines = screen.lines();
        let patterns = build(Some(&[]), &["ticket (?P<match>[A-Z]+-\\d+)".to_string()]).unwrap();
        assert_eq!(find_all(&patterns, &lines)[0].text, "ABC-123");
    }
}
