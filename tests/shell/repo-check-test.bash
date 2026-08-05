#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-helper.bash"
cd "$TEST_REPO_ROOT"

output="$(./bin/repo-check --dry-run .)"

assert_line_count "$output" 'dry-run: bash bin/dotfiles-doctor' 1
assert_line_count "$output" 'dry-run: bash tests/shell/run.bash' 1

if command -v nvim >/dev/null 2>&1; then
    assert_line_count "$output" 'dry-run: nvim --headless -u NONE -l config/nvim/tests/contextual_completion.lua' 1
else
    assert_line_count "$output" 'repo-check: SKIP contextual completion test (nvim unavailable)' 1
fi

bun_tests="$(bash tests/bun/run.bash --dry-run)"
[[ -n "$bun_tests" ]] || fail "Bun dry-run returned no test paths"
while IFS= read -r test_path; do
    [[ "$test_path" == tests/* ]] || fail "Bun dry-run selected a path outside tests/: $test_path"
done <<<"$bun_tests"
assert_not_contains "$bun_tests" 'bunsen/lib/tests'

space_test='tests/bun/repo check filename.test.ts'
trap 'rm -f "$space_test"' EXIT
: >"$space_test"
space_output="$(bash tests/bun/run.bash --dry-run)"
assert_line_count "$space_output" "$space_test" 1
rm -f "$space_test"
trap - EXIT

if command -v bun >/dev/null 2>&1; then
    assert_line_count "$output" 'dry-run: bash tests/bun/run.bash' 1
else
    assert_line_count "$output" 'repo-check: SKIP Bun tests (bun unavailable)' 1
fi
assert_not_contains "$output" 'bun test tests'
assert_not_contains "$output" 'bunsen/lib/tests'

recursive_commands="$(printf '%s\n' "$output" | grep '^dry-run: .*repo-check' || true)"
[[ -z "$recursive_commands" ]] || fail "repo-check discovered itself: $recursive_commands"

printf 'repo-check tests passed\n'
