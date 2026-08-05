#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
doctor="$repo_root/bin/context-lite-doctor"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/context-lite-doctor-test.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

large_pi_dir="$tmp_dir/large-pi"
large_runs_dir="$large_pi_dir/context-mode-lite/runs"
mkdir -p "$large_runs_dir"
marker='STORED_OUTPUT_MUST_NOT_BE_PRINTED'
i=1
while [[ "$i" -le 3000 ]]; do
    printf -v run_id 'run-%04d-with-a-long-enough-name-to-fill-the-pipe-buffer' "$i"
    mkdir -p "$large_runs_dir/$run_id"
    printf '%s\n' "$marker" >"$large_runs_dir/$run_id/output.txt"
    i=$((i + 1))
done

large_output="$(
    XDG_STATE_HOME="$tmp_dir/large-state" \
        "$doctor" --pi-dir "$large_pi_dir" --sample 1 --no-record
)" || fail "large history fixture did not exit 0"
assert_contains "$large_output" 'run outputs sampled:     1'
[[ "$large_output" != *"$marker"* ]] || fail 'stored output appeared in stdout'
[[ ! -e "$tmp_dir/large-state/context-lite-doctor/history.tsv" ]] || fail 'history was written with --no-record'

invalid_output_file="$tmp_dir/invalid-sample-output"
if "$doctor" --pi-dir "$large_pi_dir" --sample invalid --no-record >"$invalid_output_file" 2>&1; then
    fail 'invalid --sample exited 0'
else
    status=$?
fi
[[ "$status" -eq 2 ]] || fail "invalid --sample exited $status instead of 2"
invalid_output="$(<"$invalid_output_file")"
assert_contains "$invalid_output" '--sample must be a positive integer'

missing_output_file="$tmp_dir/missing-pi-output"
if "$doctor" --pi-dir "$tmp_dir/missing-pi" --no-record >"$missing_output_file" 2>&1; then
    fail 'missing Pi directory exited 0'
else
    status=$?
fi
[[ "$status" -eq 1 ]] || fail "missing Pi directory exited $status instead of 1"
missing_output="$(<"$missing_output_file")"
assert_contains "$missing_output" 'Pi directory not found:'

failure_pi_dir="$tmp_dir/failure-pi"
mkdir -p "$failure_pi_dir/context-mode-lite/runs/run-1"
printf 'error: permission denied while reading metadata\n' >"$failure_pi_dir/context-mode-lite/runs/run-1/output.txt"
failure_output="$(
    XDG_STATE_HOME="$tmp_dir/failure-state" \
        "$doctor" --pi-dir "$failure_pi_dir" --sample 10 --no-record
)" || fail 'failure-classification fixture did not exit 0'
assert_contains "$failure_output" 'run outputs sampled:     1'
assert_contains "$failure_output" 'failure-shaped outputs:  1 (100.0%)'
assert_contains "$failure_output" 'permission: 1'
[[ ! -e "$tmp_dir/failure-state/context-lite-doctor/history.tsv" ]] || fail 'classification fixture wrote history'

printf 'context-lite-doctor tests passed\n'
