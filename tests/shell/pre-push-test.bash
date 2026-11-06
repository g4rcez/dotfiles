#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-helper.bash"
command -v gitleaks >/dev/null 2>&1 || { printf 'pre-push test: SKIP (gitleaks not installed)\n'; exit 0; }

make_temp_dir
work="$REPLY"
git init -q --bare "$work/remote.git"
git clone -q "$work/remote.git" "$work/clone" 2>/dev/null
cd "$work/clone"
git config user.email test@example.com
git config user.name test
git config core.hooksPath "$TEST_REPO_ROOT/.githooks"

printf 'hello\n' >readme.txt
git add readme.txt
git commit -q -m clean
git push -q origin HEAD:main 2>/dev/null || fail "push of a clean commit was blocked"

printf 'token = ghp_1a2B3c4D5e6F7g8H9i0J1k2L3m4N5o6P7q8R\n' >config.env
git add config.env
git commit -q -m leak
if git push -q origin HEAD:main 2>"$work/err"; then
    fail "push with a secret was not blocked"
fi
assert_contains "$(<"$work/err")" "Push blocked"
printf 'pre-push test: PASS\n'
