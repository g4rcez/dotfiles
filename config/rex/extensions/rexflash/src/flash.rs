//! Flash mode: type a query, every visible match gets a label, press a label to pick it.
//! As in flash.nvim, a label never equals the character that follows a match, so the next key is
//! either a label or a longer query, never both.

use crate::patterns::Found;
use crate::screen::Line;
use std::collections::HashSet;

#[derive(Debug, PartialEq)]
pub struct Hit {
    pub line: usize,
    pub start: usize,
    pub end: usize,
}

fn fold(c: char) -> char {
    c.to_lowercase().next().unwrap_or(c)
}

/// Literal search. Smartcase: a query with no uppercase letter ignores case.
pub fn search(lines: &[Line], query: &str) -> Vec<Hit> {
    let q: Vec<char> = query.chars().collect();
    if q.is_empty() {
        return Vec::new();
    }
    let ignore_case = !q.iter().any(|c| c.is_uppercase());
    let mut hits = Vec::new();
    for (li, line) in lines.iter().enumerate() {
        let text: Vec<char> = line.text.chars().collect();
        if text.len() < q.len() {
            continue;
        }
        for start in 0..=text.len() - q.len() {
            let same = q.iter().enumerate().all(|(i, &qc)| {
                let tc = text[start + i];
                tc == qc || (ignore_case && fold(tc) == qc)
            });
            if same {
                hits.push(Hit { line: li, start, end: start + q.len() });
            }
        }
    }
    hits
}

/// Orders hits so the ones nearest the bottom (the prompt) come first, then left to right.
pub fn sort_bottom_first(hits: &mut [Hit], lines: &[Line]) {
    hits.sort_by_key(|h| {
        let (row, col) = lines[h.line].pos[h.start];
        (std::cmp::Reverse(row), col)
    });
}

/// One label per hit, in the order of `hits`. Hits past the last free letter get none.
pub fn labels(hits: &[Hit], lines: &[Line], alphabet: &[char]) -> Vec<Option<char>> {
    let mut blocked: HashSet<char> = HashSet::new();
    for h in hits {
        if let Some(next) = lines[h.line].char_at(h.end) {
            blocked.extend(next.to_lowercase());
            blocked.extend(next.to_uppercase());
        }
    }
    let free: Vec<char> = alphabet.iter().copied().filter(|c| !blocked.contains(c)).collect();
    (0..hits.len()).map(|i| free.get(i).copied()).collect()
}

/// The text a pick copies: the pattern match that covers the hit, else the whole word around it.
pub fn pick_text(lines: &[Line], found: &[Found], hit: &Hit) -> String {
    if let Some(f) = found
        .iter()
        .find(|f| f.line == hit.line && f.start <= hit.start && hit.end <= f.end)
    {
        return f.text.clone();
    }
    let chars: Vec<char> = lines[hit.line].text.chars().collect();
    let (mut s, mut e) = (hit.start, hit.end);
    while s > 0 && !chars[s - 1].is_whitespace() {
        s -= 1;
    }
    while e < chars.len() && !chars[e].is_whitespace() {
        e += 1;
    }
    let word: String = chars[s..e].iter().collect();
    let word = word.trim_matches(|c| "\"'`()[]{}<>,;".contains(c));
    if word.is_empty() {
        chars[hit.start..hit.end].iter().collect()
    } else {
        word.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::patterns;
    use crate::screen::Screen;

    fn lines(input: &str) -> Vec<Line> {
        Screen::parse(input, 80).lines()
    }

    #[test]
    fn lowercase_query_ignores_case_and_uppercase_does_not() {
        let l = lines("Foo foo\n");
        assert_eq!(search(&l, "foo").len(), 2);
        assert_eq!(search(&l, "Foo"), vec![Hit { line: 0, start: 0, end: 3 }]);
    }

    #[test]
    fn empty_query_has_no_hits() {
        assert_eq!(search(&lines("abc\n"), ""), Vec::<Hit>::new());
    }

    #[test]
    fn bottom_hits_come_first() {
        let l = lines("foo\nfoo\n");
        let mut hits = search(&l, "foo");
        sort_bottom_first(&mut hits, &l);
        assert_eq!(hits[0].line, 1);
    }

    #[test]
    fn labels_skip_the_character_after_each_match_in_either_case() {
        let l = lines("foo bar\nfoOd\n");
        let mut hits = search(&l, "fo");
        sort_bottom_first(&mut hits, &l);
        // "fo" is followed by 'o' in the first line and by 'O' in the second, so 'o' is not a free label.
        let got = labels(&hits, &l, &['o', 'a', 's']);
        assert_eq!(got, vec![Some('a'), Some('s')]);
    }

    #[test]
    fn hits_without_a_free_letter_get_no_label() {
        let l = lines("ab ab ab\n");
        let hits = search(&l, "ab");
        assert_eq!(labels(&hits, &l, &['x', 'y']), vec![Some('x'), Some('y'), None]);
    }

    #[test]
    fn pick_inside_a_pattern_match_copies_the_whole_match() {
        let l = lines("open https://example.com/x now\n");
        let found = patterns::find_all(&patterns::build(None, &[]).unwrap(), &l);
        let hit = search(&l, "exam").remove(0);
        assert_eq!(pick_text(&l, &found, &hit), "https://example.com/x");
    }

    #[test]
    fn pick_outside_any_pattern_copies_the_word_without_quotes() {
        let l = lines("say (\"hello,\" world)\n");
        let hit = search(&l, "ell").remove(0);
        assert_eq!(pick_text(&l, &[], &hit), "hello");
    }
}
