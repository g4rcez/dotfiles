#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

export LC_ALL=C
shopt -s nullglob
tests=(tests/shell/*-test.bash)

if [[ "${#tests[@]}" -eq 0 ]]; then
    printf 'shell tests: no tests found\n' >&2
    exit 1
fi

for test_file in "${tests[@]}"; do
    printf '> bash %s\n' "$test_file"
    bash "$test_file"
done

printf 'shell tests: PASS (%s files)\n' "${#tests[@]}"
