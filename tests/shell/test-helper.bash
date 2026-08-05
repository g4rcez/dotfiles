#!/usr/bin/env bash
set -euo pipefail

TEST_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_TEMP_DIRS=()

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    [[ "$haystack" != *"$needle"* ]] || fail "expected output not to contain: $needle"
}

assert_line_count() {
    local haystack="$1"
    local needle="$2"
    local expected="$3"
    local count

    count="$(printf '%s\n' "$haystack" | grep -Fxc "$needle" || true)"
    [[ "$count" == "$expected" ]] || fail "expected $expected line(s) equal to '$needle', got $count"
}

make_temp_dir() {
    REPLY="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-shell-test.XXXXXX")"
    TEST_TEMP_DIRS+=("$REPLY")
}

cleanup_test_temp_dirs() {
    local temp_dir

    [[ "${#TEST_TEMP_DIRS[@]}" -gt 0 ]] || return 0
    for temp_dir in "${TEST_TEMP_DIRS[@]}"; do
        rm -rf "$temp_dir"
    done
}

trap cleanup_test_temp_dirs EXIT
