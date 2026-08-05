#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$repo_root/bin/gh-fzf"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/gh-fzf-test.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

stub_dir="$tmp_dir/bin"
mkdir -p "$stub_dir"

cat >"$stub_dir/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1 $2" == "pr list" ]]; then
    printf '%s\n' "${GH_LIST_JSON:?}"
elif [[ "$1 $2" == "pr checkout" ]]; then
    printf '%s\n' "$*" >>"${GH_ARGS_LOG:?}"
else
    exit 64
fi
EOF

cat >"$stub_dir/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"${FZF_ARGS_LOG:?}"
cat >"${FZF_STDIN_LOG:?}"
EOF
chmod +x "$stub_dir/gh" "$stub_dir/fzf"

marker='TITLE_MARKER_$(touch should-not-exist);"quoted"'
json="$(jq -n --arg marker "$marker" '[
    {number: 17, id: "one", title: $marker, body: "first body"},
    {number: 18, id: "two", title: $marker, body: "duplicate body"}
]')"

GH_LIST_JSON="$json" \
    GH_ARGS_LOG="$tmp_dir/gh-args" \
    FZF_ARGS_LOG="$tmp_dir/fzf-args" \
    FZF_STDIN_LOG="$tmp_dir/fzf-stdin" \
    PATH="$stub_dir:$PATH" \
    "$script"

stdin="$(<"$tmp_dir/fzf-stdin")"
args="$(<"$tmp_dir/fzf-args")"
[[ "$stdin" == *$'17\t'* ]] || fail 'first numeric key was not rendered'
[[ "$stdin" == *$'18\t'* ]] || fail 'second numeric key was not rendered'
[[ "$stdin" == *"$marker"* ]] || fail 'hostile title did not reach display input'
[[ "$args" != *"$marker"* ]] || fail 'hostile title reached fzf action arguments'
[[ "$args" == *'--preview {1}'* ]] || fail 'preview does not use the first field'
[[ "$args" == *'enter:become(gh pr checkout {1})'* ]] || fail 'checkout does not use the first field'
[[ ! -e "$tmp_dir/should-not-exist" ]] || fail 'title command substitution was executed'
[[ ! -e "$tmp_dir/gh-args" ]] || fail 'checkout ran without an fzf selection'

preview_data="$tmp_dir/preview.json"
printf '%s\n' "$json" >"$preview_data"
preview="$(FZF_GITCLI_FILE="$preview_data" "$script" --preview 18)"
[[ "$preview" == 'duplicate body' ]] || fail "preview selected the wrong body: $preview"

if FZF_GITCLI_FILE="$preview_data" "$script" --preview '18;touch bad' >"$tmp_dir/invalid-output" 2>&1; then
    fail 'nonnumeric preview ID succeeded'
else
    status=$?
fi
[[ "$status" -eq 2 ]] || fail "nonnumeric preview ID exited $status instead of 2"

GH_LIST_JSON='[]' \
    GH_ARGS_LOG="$tmp_dir/empty-gh-args" \
    FZF_ARGS_LOG="$tmp_dir/empty-fzf-args" \
    FZF_STDIN_LOG="$tmp_dir/empty-fzf-stdin" \
    PATH="$stub_dir:$PATH" \
    "$script" >"$tmp_dir/empty-output"
[[ "$(<"$tmp_dir/empty-output")" == 'No pull requests available' ]] || fail 'empty-list message changed'
[[ ! -e "$tmp_dir/empty-fzf-args" ]] || fail 'fzf ran for an empty list'

printf 'gh-fzf tests passed\n'
