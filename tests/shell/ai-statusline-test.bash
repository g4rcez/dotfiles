#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$repo_root/bin/ai"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ai-statusline-test.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT
stub_dir="$tmp_dir/bin"
state_dir="$tmp_dir/agentmux-state"
mkdir -p "$stub_dir" "$tmp_dir/home" "$state_dir"
export AGENTMUX_STATE_DIR="$state_dir"

cat >"$stub_dir/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "$*" in
  *"list-panes -a -F"*)
    if [[ "${AI_STATUS_TEST_NO_AGENTS:-0}" == 1 ]]; then
      printf '%s\n' '%9|test|9|1|shell|/tmp|900|shell'
    elif [[ "${AI_STATUS_TEST_STATE:-}" == attention ]]; then
      printf '%s\n' \
        '%1|test|1|1|claude|/tmp|100|Claude' \
        '%2|test|2|1|codex|/tmp|200|✳ Codex' \
        '%3|test|3|1|gemini|/tmp|300|Gemini' \
        '%4|test|4|1|pi|/tmp|400|Pi' \
        '%5|test|5|1|omp|/tmp|500|OMP' \
        '%6|test|6|1|opencode|/tmp|600|OpenCode' \
        '%7|test|7|1|harness|/tmp|700|Harness'
    elif [[ "${AI_STATUS_TEST_STATE:-}" == running ]]; then
      printf '%s\n' \
        '%1|test|1|1|claude|/tmp|100|Claude' \
        '%2|test|2|1|codex|/tmp|200|Codex' \
        '%3|test|3|1|gemini|/tmp|300|Gemini' \
        '%4|test|4|1|pi|/tmp|400|Pi' \
        '%5|test|5|1|omp|/tmp|500|OMP' \
        '%6|test|6|1|opencode|/tmp|600|OpenCode' \
        '%7|test|7|1|harness|/tmp|700|Harness'
    else
      printf '%s\n' \
        '%1|test|1|1|claude|/tmp|100|✳ Claude' \
        '%2|test|2|1|codex|/tmp|200|✳ Codex' \
        '%3|test|3|1|gemini|/tmp|300|✳ Gemini' \
        '%4|test|4|1|pi|/tmp|400|Pi' \
        '%5|test|5|1|omp|/tmp|500|✳ OMP' \
        '%6|test|6|1|opencode|/tmp|600|✳ OpenCode' \
        '%7|test|7|1|harness|/tmp|700|✳ Harness'
    fi
    ;;
  *"capture-pane -t %4 -p"*)
    if [[ "${AI_STATUS_TEST_STATE:-}" == running || "${AI_STATUS_TEST_STATE:-}" == attention ]]; then
      printf 'Working...\n'
    fi
    ;;
  *"capture-pane -t %2 -p"*)
    if [[ "${AI_STATUS_TEST_STATE:-}" == timer ]]; then
      printf '(1m 3s)\n'
    fi
    ;;
  *"capture-pane -t "*) ;;
  *"show-options -wv -t "*" window-status-format"*)
    if [[ "${AI_STATUS_TEST_ALL_DONE:-0}" == 1 || "$*" == *"-t test:1.1 "* ]]; then
      printf 'window-status-format bg=red\n'
    else
      printf 'window-status-format bg=default\n'
    fi
    ;;
esac
EOF

cat >"$stub_dir/ps" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${AI_STATUS_TEST_NO_AGENTS:-0}" == 1 ]]; then
  printf '%s\n' '900 1 -zsh'
  exit 0
fi
printf '%s\n' \
  '100 1 -zsh' \
  '101 100 node /tmp/node_modules/@anthropic-ai/claude-code/cli.js' \
  '200 1 -zsh' \
  '201 200 node /tmp/node_modules/@openai/codex/bin/codex.js' \
  '300 1 -zsh' \
  '301 300 node /tmp/node_modules/@google/gemini-cli/dist/index.js' \
  '400 1 -zsh' \
  '401 400 node /tmp/node_modules/pi-coding-agent/dist/cli.js' \
  '500 1 -zsh' \
  '501 500 omp' \
  '600 1 -zsh' \
  '601 600 /opt/homebrew/bin/opencode' \
  '700 1 -zsh' \
  '701 700 harness'
EOF

chmod +x "$stub_dir/tmux" "$stub_dir/ps"

write_pi_state() {
    local status="$1"
    printf '%s\n' "{\"version\":1,\"agent\":\"pi\",\"status\":\"$status\",\"pane_id\":\"%4\",\"pid\":401}" >"$state_dir/tmux-4.json"
}

write_pi_state waiting
status="$(
    HOME="$tmp_dir/home" \
        DOTFILES_DIR="$repo_root" \
        TMUX='/tmp/ai-status-test.sock,123,0' \
        TMUX_PANE='%1' \
        PATH="$stub_dir:$PATH" \
        "$script" --_statusline
)"
[[ "$status" == *'󱎫 6 idle'* && "$status" == *' 1 done'* ]] || {
    printf 'FAIL: expected separate idle and done counts, got: %s\n' "$status" >&2
    exit 1
}

write_pi_state working
status="$(
    HOME="$tmp_dir/home" \
        DOTFILES_DIR="$repo_root" \
        TMUX='/tmp/ai-status-test.sock,123,0' \
        TMUX_PANE='%1' \
        AI_STATUS_TEST_STATE=running \
        PATH="$stub_dir:$PATH" \
        "$script" --_statusline
)"
[[ "$status" == *' 7 running'* ]] || {
    printf 'FAIL: expected running count when all agents are working, got: %s\n' "$status" >&2
    exit 1
}

if command -v jq >/dev/null 2>&1; then
    write_pi_state "done"
    status="$(
        HOME="$tmp_dir/home" \
            DOTFILES_DIR="$repo_root" \
            TMUX='/tmp/ai-status-test.sock,123,0' \
            TMUX_PANE='%1' \
            AI_STATUS_TEST_STATE=running \
            PATH="$stub_dir:$PATH" \
            "$script" --_statusline
    )"
    [[ "$status" == *' 6 running'* && "$status" == *'󱎫 1 idle'* ]] || {
        printf 'FAIL: expected Pi lifecycle state to override pane text, got: %s\n' "$status" >&2
        exit 1
    }
fi

write_pi_state working
status="$(
    HOME="$tmp_dir/home" \
        DOTFILES_DIR="$repo_root" \
        TMUX='/tmp/ai-status-test.sock,123,0' \
        TMUX_PANE='%1' \
        AI_STATUS_TEST_STATE=attention \
        PATH="$stub_dir:$PATH" \
        "$script" --_statusline
)"
[[ "$status" == *' 6 running'* && "$status" == *'󱎫 1 idle'* ]] || {
    printf 'FAIL: expected mixed running and idle counts, got: %s\n' "$status" >&2
    exit 1
}

write_pi_state done
status="$(
    HOME="$tmp_dir/home" \
        DOTFILES_DIR="$repo_root" \
        TMUX='/tmp/ai-status-test.sock,123,0' \
        TMUX_PANE='%1' \
        AI_STATUS_TEST_ALL_DONE=1 \
        PATH="$stub_dir:$PATH" \
        "$script" --_statusline
)"
[[ "$status" == *' 7 agents'* ]] || {
    printf 'FAIL: expected green success status when all agents are done, got: %s\n' "$status" >&2
    exit 1
}

status="$(
    HOME="$tmp_dir/home" \
        DOTFILES_DIR="$repo_root" \
        TMUX='/tmp/ai-status-test.sock,123,0' \
        TMUX_PANE='%1' \
        AI_STATUS_TEST_STATE=timer \
        AI_STATUS_TEST_ALL_DONE=1 \
        PATH="$stub_dir:$PATH" \
        "$script" --_statusline
)"
[[ "$status" == *' 1 running'* && "$status" == *' 6 done'* ]] || {
    printf 'FAIL: expected timer output to count one running agent and six done, got: %s\n' "$status" >&2
    exit 1
}

status="$(
    HOME="$tmp_dir/home" \
        DOTFILES_DIR="$repo_root" \
        TMUX='/tmp/ai-status-test.sock,123,0' \
        TMUX_PANE='%1' \
        AI_STATUS_TEST_NO_AGENTS=1 \
        PATH="$stub_dir:$PATH" \
        "$script" --_statusline
)"
[[ -z "$status" ]] || {
    printf 'FAIL: expected empty status with no agents, got: %s\n' "$status" >&2
    exit 1
}

printf 'ai statusline tests passed\n'
