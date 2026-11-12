#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-helper.bash"
cd "$TEST_REPO_ROOT"

for tool in zsh jq ssh-keygen; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'commit tests: SKIP (%s unavailable)\n' "$tool"
        exit 0
    fi
done

make_temp_dir
test_root="$(cd "$REPLY" && pwd -P)"
mkdir -p "$test_root/bin"

# Fake AI boundary: answers the split prompt from a JSON file and the message prompt from the index.
cat >"$test_root/bin/fake-ai" <<'EOF'
#!/usr/bin/env bash
cat >/dev/null
case "${1:-}" in
    *"split a set of changed files"*) cat "$FAKE_SPLIT_JSON" ;;
    *) printf 'feat: %s\n\n- change\n' "$(git diff --cached --name-only | paste -sd, -)" ;;
esac
EOF
# The real pbcopy would overwrite the clipboard of whoever runs the tests.
printf '#!/usr/bin/env bash\ncat >/dev/null\n' >"$test_root/bin/pbcopy"
chmod +x "$test_root/bin/fake-ai" "$test_root/bin/pbcopy"

ssh-keygen -q -t ed25519 -N '' -f "$test_root/key"
export GIT_CONFIG_GLOBAL="$test_root/gitconfig"
export GIT_CONFIG_NOSYSTEM=1
git config --global user.name 'Commit AI Test'
git config --global user.email 'commit-ai@example.invalid'
git config --global gpg.format ssh
git config --global user.signingkey "$test_root/key.pub"

new_repo() {
    repo="$test_root/$1"
    bare="$test_root/$1.git"
    git init -q --bare -b main "$bare"
    git init -q -b main "$repo"
    git -C "$repo" remote add origin "$bare"
    printf 'one\n' >"$repo/a.txt"
    git -C "$repo" add a.txt
    git -C "$repo" commit -q -S -m 'chore: seed'
    git -C "$repo" push -q -u origin main
    # One line per push received, holding the number of commits that push carried.
    printf '#!/usr/bin/env bash\nwhile read -r old new ref; do git rev-list --count "$old..$new" >>"%s/push-log"; done\n' "$bare" >"$bare/hooks/pre-receive"
    chmod +x "$bare/hooks/pre-receive"
    printf 'two\n' >>"$repo/a.txt"
    printf 'b\n' >"$repo/b.txt"
    printf 'c\n' >"$repo/c.txt"
}

# Usage: run_in_repo ANSWER SUBCOMMAND [ARGS]. Runs bin/commit. Sets rc and output.
run_in_repo() {
    rc=0
    output="$(
        cd "$repo" &&
            printf '%s\n' "$1" |
            DOTFILES="$TEST_REPO_ROOT" AI_QUERY_COMMAND="$test_root/bin/fake-ai" FAKE_SPLIT_JSON="$test_root/split.json" \
                PATH="$test_root/bin:$PATH" "$TEST_REPO_ROOT/bin/commit" "${@:2}" 2>&1
    )" || rc=$?
}

# Two groups and an approved split: two commits, each holding only its own files, then one push.
new_repo split-approved
printf '%s' '{"groups":[{"paths":["a.txt"],"hint":"update a"},{"paths":["b.txt","c.txt"],"hint":"add b and c"}]}' >"$test_root/split.json"
run_in_repo y ai
[[ "$rc" == 0 ]] || fail "approved split exited $rc: $output"
[[ "$(git -C "$repo" log --format=%s -n 2)" == $'feat: b.txt,c.txt\nfeat: a.txt' ]] || fail "expected one commit per group, got: $(git -C "$repo" log --format=%s)"
[[ "$(git -C "$bare" log --format=%s -n 1 main)" == 'feat: b.txt,c.txt' ]] || fail "expected the commits to be pushed"
[[ -z "$(git -C "$repo" status --porcelain)" ]] || fail "expected a clean working tree"
[[ "$(<"$bare/push-log")" == 2 ]] || fail "expected one push carrying both commits, got pushes of: $(paste -sd, "$bare/push-log")"

# The user declines: nothing is committed.
new_repo split-declined
run_in_repo n ai
[[ "$rc" != 0 ]] || fail "declined split must exit non-zero"
assert_contains "$output" 'aborted, nothing changed'
[[ "$(git -C "$repo" rev-list --count HEAD)" == 1 ]] || fail "declined split must not commit"

# The AI forgets a path: fall back to one commit with every path.
new_repo split-invalid
printf '%s' '{"groups":[{"paths":["a.txt"],"hint":"update a"}]}' >"$test_root/split.json"
run_in_repo '' ai
[[ "$rc" == 0 ]] || fail "fallback exited $rc: $output"
assert_contains "$output" 'no valid AI split'
[[ "$(git -C "$repo" log --format=%s -n 1)" == 'feat: a.txt,b.txt,c.txt' ]] || fail "expected one commit with all paths"
[[ "$(git -C "$repo" rev-list --count HEAD)" == 2 ]] || fail "expected exactly one new commit"
[[ "$(<"$bare/push-log")" == 1 ]] || fail "expected one push carrying one commit"

# A failing pre-commit hook must stop the commit: commit ai never skips hooks.
new_repo hook-fails
mkdir "$repo/.hooks"
printf '#!/usr/bin/env bash\nexit 1\n' >"$repo/.hooks/pre-commit"
chmod +x "$repo/.hooks/pre-commit"
git -C "$repo" config core.hooksPath .hooks
printf '%s' '{"groups":[{"paths":["a.txt","b.txt","c.txt"],"hint":"all"}]}' >"$test_root/split.json"
run_in_repo '' ai
[[ "$rc" != 0 ]] || fail "a failing hook must fail commit ai"
assert_contains "$output" 'commit 1 of 1 failed'
[[ "$(git -C "$repo" rev-list --count HEAD)" == 1 ]] || fail "a failing hook must not create a commit"

# The shorthand helpers stage the changed paths and keep the hooks: a failing hook blocks them.
new_repo docs-helper
run_in_repo '' docs
[[ "$rc" == 0 ]] || fail "commit docs exited $rc: $output"
[[ "$(git -C "$bare" log --format=%s -n 1 main)" == 'docs: update documentation' ]] || fail "expected commit docs to commit and push"
[[ "$(git -C "$repo" show --name-only --format= HEAD)" == $'a.txt\nb.txt\nc.txt' ]] || fail "expected commit docs to commit every changed path"

new_repo wip-hook-fails
mkdir "$repo/.hooks"
printf '#!/usr/bin/env bash\nexit 1\n' >"$repo/.hooks/pre-commit"
chmod +x "$repo/.hooks/pre-commit"
git -C "$repo" config core.hooksPath .hooks
run_in_repo '' wip
[[ "$rc" != 0 ]] || fail "a failing hook must fail commit wip"
[[ "$(git -C "$repo" rev-list --count HEAD)" == 1 ]] || fail "commit wip must not skip the hooks"
git -C "$repo" add a.txt
run_in_repo '' staged
[[ "$rc" != 0 ]] || fail "a failing hook must fail commit staged"
[[ "$(git -C "$repo" rev-list --count HEAD)" == 1 ]] || fail "commit staged must not skip the hooks"

new_repo helper-nothing
git -C "$repo" checkout -q -- a.txt
rm "$repo/b.txt" "$repo/c.txt"
run_in_repo '' docs
[[ "$rc" != 0 ]] || fail "commit docs with no changes must fail"
assert_contains "$output" 'nothing to commit'

printf 'commit tests passed\n'
