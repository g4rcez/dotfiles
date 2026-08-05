#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

dry_run=0
if [[ "${1:-}" == "--dry-run" ]]; then
    dry_run=1
    shift
fi

if [[ "$#" -ne 0 ]]; then
    printf 'bun tests: usage: bash tests/bun/run.bash [--dry-run]\n' >&2
    exit 2
fi

tests=()
while IFS= read -r -d '' test_file; do
    tests+=("$test_file")
done < <(find tests -type f -name '*.test.ts' -print0)

if [[ "${#tests[@]}" -eq 0 ]]; then
    printf 'bun tests: no tests found below tests/\n' >&2
    exit 1
fi

if [[ "$dry_run" == "1" ]]; then
    printf '%s\n' "${tests[@]}"
    exit 0
fi

printf '> bun test'
printf ' %q' "${tests[@]}"
printf '\n'
bun test "${tests[@]}"
