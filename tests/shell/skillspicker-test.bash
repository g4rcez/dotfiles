#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$repo_root/bin/skillspicker"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/skillspicker-test.XXXXXX")"
tmp_dir="$(cd "$tmp_dir" && pwd -P)"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

project="$tmp_dir/project with spaces"
home="$tmp_dir/home with spaces"
stub_dir="$tmp_dir/bin"
local_skill="$project/.claude/skills/local skill/SKILL.md"
project_duplicate="$project/.agents/skills/shared-skill/SKILL.md"
home_duplicate="$home/.pi/agent/skills/shared-skill/SKILL.md"
home_skill="$home/.pi/agent/skills/home-skill/SKILL.md"
missing_skill="$project/.agents/skills/not-a-skill"

mkdir -p "${local_skill%/*}" "${project_duplicate%/*}" "${home_duplicate%/*}" \
    "${home_skill%/*}" "$missing_skill" "$stub_dir"
printf '# local skill\n' >"$local_skill"
printf '# project shared skill\n' >"$project_duplicate"
printf '# home shared skill\n' >"$home_duplicate"
printf '# home skill\n' >"$home_skill"

cat >"$stub_dir/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"${FZF_ARGS_LOG:?}"
printf '%s\n' "${FZF_SELECTED_LINE:?}"
EOF

cat >"$stub_dir/pbcopy" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat >"${CLIPBOARD_LOG:?}"
EOF
chmod +x "$stub_dir/fzf" "$stub_dir/pbcopy"

cd "$project"
entries="$(HOME="$home" "$script" --_list)"
project_entry=$'[project] shared-skill\t'"$project_duplicate"
local_entry=$'[project] local skill\t'"$local_skill"
home_entry=$'[global] home-skill\t'"$home_skill"
[[ "$entries" == "$project_entry"$'\n'* ]] || fail 'project skills were not prioritized'
[[ "$entries" == *"$local_entry"* ]] || fail 'project skill was not listed with its SKILL.md path'
[[ "$entries" == *"$home_entry"* ]] || fail 'home skill was not listed by name with its SKILL.md path'
[[ "$entries" != *"$home_duplicate"* ]] || fail 'duplicate home skill was not replaced by its project version'
[[ "$entries" != *'not-a-skill'* ]] || fail 'directory without SKILL.md was listed'

output="$(
    HOME="$home" \
        PATH="$stub_dir:$PATH" \
        FZF_ARGS_LOG="$tmp_dir/fzf-args" \
        FZF_SELECTED_LINE="$local_entry" \
        CLIPBOARD_LOG="$tmp_dir/clipboard" \
        "$script" --agent-mode
)"
[[ "$output" == "@$local_skill" ]] || fail "unexpected selected output: $output"
[[ "$(<"$tmp_dir/clipboard")" == "@$local_skill" ]] || fail 'selected path was not copied'
fzf_args="$(<"$tmp_dir/fzf-args")"
[[ "$fzf_args" == *'--no-sort'* ]] || fail 'fzf does not preserve project-first ordering'
[[ "$fzf_args" == *'--with-nth=1'* ]] || fail 'fzf does not display the skill-name field'
[[ "$fzf_args" == *'start:reload('*'--_list'* ]] || fail 'fzf does not load discovered skills on start'
[[ "$fzf_args" == *'ctrl-r:reload('*'--_refresh'* ]] || fail 'fzf does not refresh the skill list'
[[ "$fzf_args" == *'{2}'* ]] || fail 'preview does not use the SKILL.md path field'

printf 'skillspicker tests passed\n'
