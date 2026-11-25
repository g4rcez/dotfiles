#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-helper.bash"

make_temp_dir
tmp_dir="$(cd "$REPLY" && pwd)" # macOS TMPDIR ends with "/": normalize the "//"
project_dir="$tmp_dir/project"
sessions_dir="$tmp_dir/home/.claude/projects/-project"
mkdir -p "$tmp_dir/bin" "$project_dir" "$sessions_dir"

printf '%s\n' '{"type":"user","message":{"content":"fix the needle bug"},"cwd":"'"$project_dir"'"}' \
    >"$sessions_dir/aaaa-1111.jsonl"
printf '%s\n' '{"type":"user","message":{"content":"write the docs"},"cwd":"'"$project_dir"'"}' \
    >"$sessions_dir/bbbb-2222.jsonl"
printf '%s\n' \
    '{"type":"ai-title","aiTitle":"Generated name","sessionId":"bbbb-2222"}' \
    '{"type":"custom-title","customTitle":"Payment retries","sessionId":"bbbb-2222"}' \
    >>"$sessions_dir/bbbb-2222.jsonl"
printf '%s\n' '{"type":"user","message":{"content":"say \"hello\" twice"},"cwd":"'"$project_dir"'"}' \
    '{"type":"ai-title","aiTitle":"Greeting script","sessionId":"cccc-3333"}' \
    >"$sessions_dir/cccc-3333.jsonl"

# Search input, newest first: modification time and transcript path.
printf '%s\t%s\n' \
    1700200000 "$sessions_dir/cccc-3333.jsonl" \
    1700100000 "$sessions_dir/bbbb-2222.jsonl" \
    1700000000 "$sessions_dir/aaaa-1111.jsonl" \
    >"$tmp_dir/index"

cat >"$tmp_dir/bin/claude" <<'EOF'
#!/usr/bin/env bash
printf '%s|%s\n' "$PWD" "$*"
EOF
chmod +x "$tmp_dir/bin/claude"

# Real fzf in filter mode: it picks the matches of the query without a terminal.
printf '%s\n' '--filter=needle' '--exact' >"$tmp_dir/fzfrc"

run_ai() {
    TZ=UTC env -u AI_COMMAND_PROMPT -u AI_CLI_NAME -u AI_CLI_MODEL -u AI_PROVIDER \
        HOME="$tmp_dir/home" \
        DOTFILES_DIR="$TEST_REPO_ROOT" \
        FZF_DEFAULT_OPTS_FILE="$tmp_dir/fzfrc" \
        PATH="$tmp_dir/bin:$PATH" \
        "$TEST_REPO_ROOT/bin/ai" "$@"
}

expected="$project_dir|--dangerously-skip-permissions --resume aaaa-1111"

output="$(run_ai query claude)"
[[ "$output" == "$expected" ]] || fail "ai query claude: got: $output"

output="$(run_ai claude)"
[[ "$output" == "$expected" ]] || fail "ai claude: got: $output"

if output="$(run_ai query unknown 2>&1)"; then
    fail "ai query unknown: expected a failure"
fi
assert_contains "$output" 'Usage: ai query <harness>'

search() {
    run_ai --_query-claude-rows "$tmp_dir/index" "$1" | cut -f6
}

: >"$tmp_dir/fzfrc"

[[ "$(search 'payment')" == 'bbbb-2222' ]] || fail "search by custom title"
[[ -z "$(search 'generated')" ]] || fail "the custom title must replace the generated title"
[[ "$(search 'greeting')" == 'cccc-3333' ]] || fail "search by generated title"
[[ "$(search 'say "hello" twice')" == 'cccc-3333' ]] || fail "search by description with quotes"
[[ "$(search '2023-11-14')" == 'aaaa-1111' ]] || fail "search by date"
[[ "$(search '2023-11-16 docs')" == 'bbbb-2222' ]] || fail "search by date and description"
[[ -z "$(search 'ndl')" ]] || fail "words must match exactly by default"
[[ "$(search '')" == $'cccc-3333\nbbbb-2222\naaaa-1111' ]] || fail "expected newest first"

printf 'ai query test: PASS\n'
