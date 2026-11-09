#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-helper.bash"
cd "$TEST_REPO_ROOT"

# Scripts that call `fzf` must source config/zsh/fzf.sh to share one layout.
# Legacy zellij scripts are not in use (tmux and Rex replaced them).
fzf_layout_allowlist=(
    bin/_legacy-worktree
    bin/zellij-sessionx
    bin/zellij-sessionx-kill
)

is_allowed() {
    local file="$1"
    local allowed
    for allowed in "${fzf_layout_allowlist[@]}"; do
        [[ "$file" == "$allowed" ]] && return 0
    done
    return 1
}

checked=0
while IFS= read -r file; do
    is_allowed "$file" && continue
    checked=$((checked + 1))
    grep -q 'config/zsh/fzf\.sh' "$file" || fail "$file calls fzf but does not source config/zsh/fzf.sh"
done < <(git ls-files 'bin/*' | xargs grep -lE '^[^#]*(^|[|;&(]|\$\()[[:space:]]*fzf([[:space:])]|$)')

[[ "$checked" -gt 0 ]] || fail "no fzf scripts found; the test pattern is broken"
printf 'fzf layout test: PASS (%s scripts)\n' "$checked"
