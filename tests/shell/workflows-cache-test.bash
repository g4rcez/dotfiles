#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$repo_root/bin/workflows"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/workflows-cache-test.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

stub_dir="$tmp_dir/bin"
xdg_cache="$tmp_dir/xdg cache"
mkdir -p "$stub_dir"

cat >"$stub_dir/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "${WORKFLOWS_CACHE:-missing}" >>"${GH_CACHE_LOG:?}"
if [[ "${1:-} ${2:-} ${3:-}" == "run list --status" ]]; then
    if [[ " $* " == *' in_progress '* ]]; then
        printf '%s\n' '[{"databaseId":123,"name":"CI","headBranch":"feature/cache","status":"in_progress","createdAt":"2025-01-01T00:00:00Z"}]'
    else
        printf '%s\n' '[]'
    fi
elif [[ "${1:-} ${2:-}" == "run view" ]]; then
    printf 'workflow preview\n'
else
    exit 64
fi
EOF

cat >"$stub_dir/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[[ -f "${WORKFLOWS_CACHE:?}" ]] || exit 70
printf '%s\n' "$WORKFLOWS_CACHE" >>"${FZF_CACHE_LOG:?}"
input="$(cat)"
printf '%s\n' "$input" >"${FZF_INPUT_LOG:?}"
id="${input%%$'\t'*}"
"${WORKFLOW_SCRIPT:?}" --preview "$id" >"${PREVIEW_OUTPUT:?}"
"$WORKFLOW_SCRIPT" --list-lines >"${RELOAD_OUTPUT:?}"
printf '%s\n' "$WORKFLOWS_CACHE" >>"$FZF_CACHE_LOG"
EOF
chmod +x "$stub_dir/gh" "$stub_dir/fzf"

run_picker() {
    local run_number="$1"
    HOME="$tmp_dir/home" \
        XDG_CACHE_HOME="$xdg_cache" \
        PATH="$stub_dir:/usr/bin:/bin:/usr/sbin:/sbin" \
        GH_CACHE_LOG="$tmp_dir/gh-cache-$run_number" \
        FZF_CACHE_LOG="$tmp_dir/fzf-cache-$run_number" \
        FZF_INPUT_LOG="$tmp_dir/fzf-input-$run_number" \
        PREVIEW_OUTPUT="$tmp_dir/preview-$run_number" \
        RELOAD_OUTPUT="$tmp_dir/reload-$run_number" \
        WORKFLOW_SCRIPT="$script" \
        "$script"
}

run_picker 1
first_cache="$(head -n 1 "$tmp_dir/fzf-cache-1")"
[[ "$first_cache" == "$xdg_cache/gh-workflows/"* ]] || fail "cache escaped XDG root: $first_cache"
[[ ! -e "$first_cache" ]] || fail 'first cache was not cleaned on exit'
[[ "$(<"$tmp_dir/fzf-cache-1")" == "$first_cache"$'\n'"$first_cache" ]] || fail 'fzf subprocess did not keep one shared cache'
while IFS= read -r observed_cache; do
    [[ "$observed_cache" == "$first_cache" ]] || fail 'gh subprocess received a different cache path'
done <"$tmp_dir/gh-cache-1"
[[ "$(<"$tmp_dir/preview-1")" == *'workflow preview'* ]] || fail 'preview subprocess did not use the cache'
[[ "$(<"$tmp_dir/reload-1")" == *$'123\t'* ]] || fail 'reload subprocess did not use the cache'

run_picker 2
second_cache="$(head -n 1 "$tmp_dir/fzf-cache-2")"
[[ "$second_cache" != "$first_cache" ]] || fail 'interactive runs reused a predictable cache path'
[[ ! -e "$second_cache" ]] || fail 'second cache was not cleaned on exit'

cache_dir="$xdg_cache/gh-workflows"
[[ -d "$cache_dir" ]] || fail 'private cache directory was not created'
if [[ "$(uname -s)" != 'Windows_NT' ]]; then
    mode="$(stat -f '%Lp' "$cache_dir" 2>/dev/null || stat -c '%a' "$cache_dir")"
    [[ "$mode" == '700' ]] || fail "cache directory mode is $mode instead of 700"
fi

if WORKFLOWS_CACHE='' PATH="$stub_dir:/usr/bin:/bin" "$script" --list-lines >"$tmp_dir/missing-output" 2>&1; then
    fail 'internal list command accepted a missing cache'
else
    status=$?
fi
[[ "$status" -eq 2 ]] || fail "missing internal cache exited $status instead of 2"

printf 'workflows cache tests passed\n'
