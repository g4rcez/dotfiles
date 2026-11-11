//! Prefix-free hint labels.

/// Returns labels in priority order: the first label is for the most important match.
/// It returns fewer than `count` labels when `count` is more than `alphabet.len()` squared.
///
/// Labels are one or two letters. With `a` letters and `n` matches, `s` letters stay single and the
/// other `a - s` letters become the first letter of two-letter labels. `s` is the largest value for
/// which `s + (a - s) * a >= n`.
pub fn assign(count: usize, alphabet: &[char]) -> Vec<String> {
    let a = alphabet.len();
    if a < 2 {
        return Vec::new();
    }
    let n = count.min(a * a);
    if n <= a {
        return alphabet[..n].iter().map(|c| c.to_string()).collect();
    }
    let single = (a * a - n) / (a - 1);
    let mut labels: Vec<String> = alphabet[..single].iter().map(|c| c.to_string()).collect();
    'outer: for first in &alphabet[single..] {
        for second in alphabet {
            if labels.len() == n {
                break 'outer;
            }
            labels.push(format!("{first}{second}"));
        }
    }
    labels
}

#[cfg(test)]
mod tests {
    use super::*;

    fn abc() -> Vec<char> {
        vec!['a', 'b', 'c']
    }

    #[test]
    fn few_matches_get_single_letters() {
        assert_eq!(assign(2, &abc()), vec!["a", "b"]);
    }

    #[test]
    fn more_matches_than_letters_turn_the_last_letter_into_a_prefix() {
        assert_eq!(assign(5, &abc()), vec!["a", "b", "ca", "cb", "cc"]);
    }

    #[test]
    fn many_matches_use_only_two_letter_labels() {
        assert_eq!(
            assign(9, &abc()),
            vec!["aa", "ab", "ac", "ba", "bb", "bc", "ca", "cb", "cc"]
        );
    }

    #[test]
    fn too_many_matches_are_capped() {
        assert_eq!(assign(100, &abc()).len(), 9);
    }

    #[test]
    fn no_label_is_the_prefix_of_another() {
        let labels = assign(7, &abc());
        let clash = labels.iter().any(|x| labels.iter().any(|y| x != y && y.starts_with(x.as_str())));
        assert!(!clash);
    }

    #[test]
    fn zero_matches_and_tiny_alphabet_give_nothing() {
        assert_eq!(assign(0, &abc()), Vec::<String>::new());
        assert_eq!(assign(3, &['a']), Vec::<String>::new());
    }
}
