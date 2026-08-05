#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
hook="$repo_root/config/claude/hooks/format-on-edit.sh"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/format-on-edit-test.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

run_hook() {
    local path="$1"
    shift
    printf '{"tool_input":{"file_path":%s}}\n' "$(jq -Rn --arg value "$path" '$value')" |
        env "$@" "$hook"
}

project="$tmp_dir/project"
local_bin="$project/node_modules/.bin"
mkdir -p "$local_bin"
printf '{}\n' >"$project/biome.json"
unsafe_file="$project/unsafe.ts"
printf 'const unsafe = true\n' >"$unsafe_file"
cat >"$local_bin/biome" <<'EOF'
#!/usr/bin/env bash
printf 'executed\n' >"${FORMAT_MARKER:?}"
EOF
chmod +x "$local_bin/biome"

unsafe_output="$(run_hook "$unsafe_file" PATH="$local_bin:/usr/bin:/bin" FORMAT_MARKER="$tmp_dir/untrusted-marker")"
[[ -z "$unsafe_output" ]] || fail 'untrusted formatter produced hook output'
[[ ! -e "$tmp_dir/untrusted-marker" ]] || fail 'project-local formatter executed'

trusted_bin="$tmp_dir/trusted-bin"
mkdir -p "$trusted_bin"
cat >"$trusted_bin/biome" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" >"${FORMAT_ARGS_LOG:?}"
EOF
chmod +x "$trusted_bin/biome"
trusted_file="$project/file with spaces.ts"
printf 'const trusted = true\n' >"$trusted_file"
trusted_output="$(run_hook "$trusted_file" PATH="$trusted_bin:/usr/bin:/bin" FORMAT_ARGS_LOG="$tmp_dir/trusted-args")"
[[ -z "$trusted_output" ]] || fail 'unchanged trusted formatting produced hook output'
trusted_args="$(<"$tmp_dir/trusted-args")"
expected_args="$(printf 'format\n--write\n%s' "$trusted_file")"
[[ "$trusted_args" == "$expected_args" ]] || fail 'trusted biome arguments were changed or split'

no_formatter_output="$(run_hook "$trusted_file" PATH="/usr/bin:/bin")"
[[ -z "$no_formatter_output" ]] || fail 'missing formatter did not exit silently'

failure_bin="$tmp_dir/failure-bin"
mkdir -p "$failure_bin"
cat >"$failure_bin/biome" <<'EOF'
#!/usr/bin/env bash
printf 'formatter failure detail\n' >&2
exit 7
EOF
chmod +x "$failure_bin/biome"
failure_output="$(run_hook "$trusted_file" PATH="$failure_bin:/usr/bin:/bin")"
[[ "$(jq -r '.decision' <<<"$failure_output")" == 'block' ]] || fail 'formatter failure did not block'
[[ "$(jq -r '.reason' <<<"$failure_output")" == *'Formatter (biome) failed'* ]] || fail 'formatter failure reason changed'
[[ "$(jq -r '.hookSpecificOutput' <<<"$failure_output")" == *'formatter failure detail'* ]] || fail 'formatter output was not reported'

printf 'format-on-edit tests passed\n'
