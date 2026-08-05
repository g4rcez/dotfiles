#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-helper.bash"
cd "$TEST_REPO_ROOT"

# TODO: Replace these existing non-portable /bin/env shebangs with /usr/bin/env.
invalid_bash_shebang_allowlist=(
    bin/tmux-fzf-preview
    bin/zellij-sessionx-preview
)

is_invalid_shebang_allowed() {
    local file="$1"
    local allowed

    for allowed in "${invalid_bash_shebang_allowlist[@]}"; do
        [[ "$file" == "$allowed" ]] && return 0
    done
    return 1
}

make_temp_dir
files_file="$REPLY/files"
git ls-files -z >"$files_file"
git ls-files --others --exclude-standard -z >>"$files_file"

bash_count=0
zsh_count=0
while IFS= read -r -d '' file; do
    [[ -f "$file" ]] || continue
    IFS= read -r first_line <"$file" || first_line=''

    if [[ "$file" == bin/* && -x "$file" && "$first_line" != '#!'* ]]; then
        if ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
            fail "executable bin file has no shebang: $file"
        fi
    fi

    interpreter=''
    case "$first_line" in
    '#!/usr/bin/env bash' | '#!/bin/bash' | '#!/usr/bin/bash')
        interpreter=bash
        ;;
    '#!/bin/env bash')
        is_invalid_shebang_allowed "$file" || fail "invalid Bash shebang: $file"
        interpreter=bash
        ;;
    '#!/usr/bin/env zsh' | '#!/bin/zsh' | '#!/usr/bin/zsh')
        interpreter=zsh
        ;;
    esac

    case "$interpreter" in
    bash)
        bash -n "$file"
        bash_count=$((bash_count + 1))
        ;;
    zsh)
        if command -v zsh >/dev/null 2>&1; then
            zsh -n "$file"
            zsh_count=$((zsh_count + 1))
        fi
        ;;
    esac
done <"$files_file"

if ! command -v zsh >/dev/null 2>&1; then
    printf 'syntax tests: SKIP zsh (zsh unavailable)\n'
fi
printf 'syntax tests: PASS (bash=%s, zsh=%s)\n' "$bash_count" "$zsh_count"
