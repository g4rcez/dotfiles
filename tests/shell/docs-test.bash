#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/test-helper.bash"

readme="$(<"$TEST_REPO_ROOT/README.md")"
nvim_readme="$(<"$TEST_REPO_ROOT/config/nvim/README.md")"
docs="$readme
$nvim_readme"

assert_not_contains "$docs" 'bunsen sync'
assert_not_contains "$docs" 'karabiner.config.ts'
assert_not_contains "$docs" 'espanso.config.ts'
assert_not_contains "$docs" '`git/gitconfig`'
assert_not_contains "$docs" 'dotfiles/git/gitconfig'
assert_not_contains "$nvim_readme" 'includes Neovim config symlink'

assert_contains "$readme" 'bun install --frozen-lockfile'
assert_contains "$readme" 'bunx bunsen validate'
assert_contains "$readme" 'bunx bunsen diff'
assert_contains "$readme" 'bunx bunsen apply'

for documented_path in \
    dotfiles.config.ts \
    bunsen/espanso.ts \
    bunsen/karabiner.ts \
    config/git/gitconfig \
    config/nvim \
    install; do
    [[ -e "$TEST_REPO_ROOT/$documented_path" ]] || fail "documented path does not exist: $documented_path"
done

printf 'documentation tests passed\n'
