#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$repo_root/bin/worktree"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/worktree-test.XXXXXX")"
tmp_dir="$(cd "$tmp_dir" && pwd -P)"
fixture_home="$tmp_dir/home"
main_path="$tmp_dir/main repo"
repo_name="$(basename "$main_path")"
linked_base="$fixture_home/.tmp/git/$repo_name"
feature_path="$linked_base/feature linked path"
detached_path="$linked_base/detached linked path"

cleanup() {
    git -C "$main_path" worktree remove --force "$feature_path" >/dev/null 2>&1 || true
    git -C "$main_path" worktree remove --force "$detached_path" >/dev/null 2>&1 || true
    rm -rf "$tmp_dir"
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

mkdir -p "$main_path" "$linked_base"
git -C "$main_path" init -q
git -C "$main_path" config user.name 'Worktree Test'
git -C "$main_path" config user.email 'worktree@example.invalid'
printf 'fixture\n' >"$main_path/file.txt"
git -C "$main_path" add file.txt
git -C "$main_path" commit -qm 'fixture commit'
git -C "$main_path" worktree add -qb 'feature/space-path' "$feature_path"
git -C "$main_path" worktree add -q --detach "$detached_path" HEAD
printf 'dirty\n' >"$feature_path/dirty file.txt"

stub_dir="$tmp_dir/bin"
mkdir -p "$stub_dir"
cat >"$stub_dir/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"${TMUX_LOG:?}"
case "${1:-}" in
    has-session|list-sessions) exit 1 ;;
esac
EOF
cat >"$stub_dir/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
input="$(cat)"
printf '%s\n' "$input" >"${FZF_INPUT_LOG:?}"
printf '%s\n' "$@" >"${FZF_ARGS_LOG:?}"
while IFS= read -r line; do
    if [[ "$line" == *"${FZF_SELECT_PATH:?}"* ]]; then
        printf '%s\n' "$line"
        exit 0
    fi
done <<<"$input"
exit 1
EOF
chmod +x "$stub_dir/tmux" "$stub_dir/fzf"

env_base=(
    HOME="$fixture_home"
    PATH="$stub_dir:/usr/bin:/bin:/usr/sbin:/sbin"
    FZF_COLORS=""
    TMUX_LOG="$tmp_dir/tmux.log"
)

default_path="$(cd "$feature_path" && env "${env_base[@]}" "$script" cd)"
[[ "$default_path" == "$main_path" ]] || fail "default cd truncated the main path: $default_path"

list_lines="$(cd "$main_path" && env "${env_base[@]}" "$script" _list_lines)"
[[ "$list_lines" == *"$main_path"* ]] || fail 'list omitted or truncated the main path'
feature_display="\\~${feature_path#"$fixture_home"}"
detached_display="\\~${detached_path#"$fixture_home"}"
[[ "$list_lines" == *"$feature_display"* ]] || fail 'list omitted or truncated the feature display path'
[[ "$list_lines" == *"$detached_display"* ]] || fail 'list omitted or truncated the detached display path'
[[ "$list_lines" == *'feature/space-path'* ]] || fail 'branch slash was not preserved'
[[ "$list_lines" == *'detached linked path'* ]] || fail 'detached worktree display changed'

: >"$tmp_dir/tmux.log"
cd "$main_path"
env "${env_base[@]}" \
    FZF_INPUT_LOG="$tmp_dir/list-fzf-input" \
    FZF_ARGS_LOG="$tmp_dir/list-fzf-args" \
    FZF_SELECT_PATH="$feature_display" \
    "$script" list
list_tmux="$(<"$tmp_dir/tmux.log")"
[[ "$list_tmux" == *"new-session -d -s feature-space-path -c $feature_path"* ]] || fail 'list passed a truncated path to tmux'
[[ "$(<"$tmp_dir/list-fzf-input")" == *"$feature_display"* ]] || fail 'list fzf input truncated the display path'
[[ "$(<"$tmp_dir/list-fzf-args")" == *'--delimiter='* ]] || fail 'list does not use an unambiguous fzf field'

: >"$tmp_dir/tmux.log"
env "${env_base[@]}" \
    FZF_INPUT_LOG="$tmp_dir/mux-fzf-input" \
    FZF_ARGS_LOG="$tmp_dir/mux-fzf-args" \
    FZF_SELECT_PATH="$detached_path" \
    "$script" mux
mux_tmux="$(<"$tmp_dir/tmux.log")"
[[ "$mux_tmux" == *"new-session -d -s detached linked path -c $detached_path"* ]] || fail 'mux passed a truncated detached path to tmux'
[[ "$(<"$tmp_dir/mux-fzf-input")" == *"$detached_path"* ]] || fail 'mux fzf input truncated the path'

overview="$(env "${env_base[@]}" "$script" overview)"
feature_overview="$(printf '%s\n' "$overview" | grep 'feature/space-path' || true)"
[[ -n "$feature_overview" ]] || fail 'overview omitted the slash branch'
[[ "$feature_overview" == *' 1 '* ]] || fail "overview did not inspect the dirty spaced path: $feature_overview"
[[ "$overview" == *'detached linked path'* ]] || fail 'overview omitted the detached worktree'

printf 'worktree tests passed\n'
