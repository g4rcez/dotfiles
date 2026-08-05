#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
installer="$repo_root/install"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/install-test.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

stub_dir="$tmp_dir/bin"
mkdir -p "$stub_dir"
cat >"$stub_dir/mise" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat >"$stub_dir/curl" <<'EOF'
#!/usr/bin/env bash
printf 'FAIL: install attempted network access\n' >&2
exit 99
EOF
chmod +x "$stub_dir/mise" "$stub_dir/curl"

run_install() {
    local home="$1"
    HOME="$home" PATH="$stub_dir:/usr/bin:/bin:/usr/sbin:/sbin" "$installer"
}

missing_home="$tmp_dir/missing"
mkdir -p "$missing_home"
run_install "$missing_home"
[[ -L "$missing_home/.zshrc" ]] || fail 'missing destination did not become a symlink'
[[ "$missing_home/.zshrc" -ef "$repo_root/config/zsh/zshrc" ]] || fail 'new symlink has the wrong target'

correct_home="$tmp_dir/correct"
mkdir -p "$correct_home"
ln -s "$repo_root/config/zsh/zshrc" "$correct_home/.zshrc"
correct_before="$(readlink "$correct_home/.zshrc")"
run_install "$correct_home"
[[ "$(readlink "$correct_home/.zshrc")" == "$correct_before" ]] || fail 'correct symlink changed'

regular_home="$tmp_dir/regular"
mkdir -p "$regular_home"
printf 'sentinel regular file\n' >"$regular_home/.zshrc"
if run_install "$regular_home" >"$tmp_dir/regular-output" 2>&1; then
    fail 'regular destination was accepted'
fi
[[ "$(<"$regular_home/.zshrc")" == 'sentinel regular file' ]] || fail 'regular destination changed'
grep -q 'refusing to replace existing' "$tmp_dir/regular-output" || fail 'regular-file error was not clear'

different_home="$tmp_dir/different"
mkdir -p "$different_home"
printf 'different target\n' >"$different_home/other-zshrc"
ln -s "$different_home/other-zshrc" "$different_home/.zshrc"
different_before="$(readlink "$different_home/.zshrc")"
if run_install "$different_home" >"$tmp_dir/different-output" 2>&1; then
    fail 'different symlink was accepted'
fi
[[ "$(readlink "$different_home/.zshrc")" == "$different_before" ]] || fail 'different symlink changed'
[[ "$(<"$different_home/other-zshrc")" == 'different target' ]] || fail 'different symlink target changed'

broken_home="$tmp_dir/broken"
mkdir -p "$broken_home"
ln -s "$broken_home/missing-target" "$broken_home/.zshrc"
broken_before="$(readlink "$broken_home/.zshrc")"
if run_install "$broken_home" >"$tmp_dir/broken-output" 2>&1; then
    fail 'broken symlink was accepted'
fi
[[ -L "$broken_home/.zshrc" ]] || fail 'broken symlink was removed'
[[ "$(readlink "$broken_home/.zshrc")" == "$broken_before" ]] || fail 'broken symlink changed'

printf 'install tests passed\n'
