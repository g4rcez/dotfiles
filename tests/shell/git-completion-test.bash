#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-helper.bash"
cd "$TEST_REPO_ROOT"

if ! command -v zsh >/dev/null 2>&1; then
    printf 'git completion tests: SKIP zsh (zsh unavailable)\n'
    exit 0
fi

make_temp_dir
test_root="$REPLY"
mkdir -p "$test_root/bin"
git init --quiet "$test_root/repo-one"
git init --quiet "$test_root/repo-two"

cat >"$test_root/bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"$GH_CALLS"
if [[ "${GH_MODE:-online}" == offline ]]; then
    exit 1
fi

case "$1 $2" in
    'pr list')
        printf '1:#1 First PR\n'
        ;;
    'workflow list')
        printf 'ci\n'
        ;;
esac
EOF
chmod +x "$test_root/bin/gh"

cat >"$test_root/completion-test.zsh" <<'EOF'
compdef() { :; }
_describe() { :; }
_values() { :; }

source "$GIT_CONFIG"
rehash
cd "$TEST_REPO"

_git_pr_numbers
_git_pr_numbers
_gh_workflow_files
_gh_workflow_files
[[ "$(wc -l <"$GH_CALLS")" -eq 2 ]] || exit 1
[[ "$_git_pr_numbers_cache" == '1:#1 First PR' ]] || exit 1
[[ "$_gh_workflow_files_cache" == 'ci' ]] || exit 1

SECONDS=31
GH_MODE=offline
_git_pr_numbers
_git_pr_numbers
_gh_workflow_files
_gh_workflow_files
[[ "$(wc -l <"$GH_CALLS")" -eq 4 ]] || exit 1
[[ "$_git_pr_numbers_cache" == '1:#1 First PR' ]] || exit 1
[[ "$_gh_workflow_files_cache" == 'ci' ]] || exit 1

cd "$OTHER_REPO"
_git_pr_numbers
[[ "$(wc -l <"$GH_CALLS")" -eq 5 ]] || exit 1
[[ -z "$_git_pr_numbers_cache" ]] || exit 1
EOF

GH_CALLS="$test_root/gh.calls" \
GH_MODE=online \
GIT_CONFIG="$TEST_REPO_ROOT/config/zsh/git.sh" \
TEST_REPO="$test_root/repo-one" \
OTHER_REPO="$test_root/repo-two" \
PATH="$test_root/bin:$PATH" \
zsh -f "$test_root/completion-test.zsh"

printf 'git completion tests: PASS\n'
