---
name: shell-bash
description: "Write, review, debug, and test Bash shell scripts and shell configuration safely. Use this skill whenever a task edits a .sh file, Bash script, shell startup file, command wrapper, environment export, arithmetic expansion, quoting, path handling, or subprocess logic—even when the user does not explicitly say Bash. First identify the target shell; do not apply Bash rules to zsh files. Pay special attention to preventing 'bad math expression' and operand errors caused by paths or other untrusted strings entering arithmetic contexts."
---

# Bash shell engineering

Write the smallest shell code that is correct for the target interpreter, safe with hostile input, and testable without changing the user's shell. Treat shell syntax, expansion, exit status, and the surrounding load chain as part of the behavior.

## 1. Identify the shell before editing

- Read the shebang. A `.sh` suffix does not identify the shell.
- Inspect how the file is invoked: executed, sourced by Bash, sourced by zsh, or embedded in another command.
- Do not mix Bash and zsh syntax. In particular, zsh's `commands[...]`, `$+commands[...]`, arrays, options, and completion APIs are not Bash.
- For a sourceable startup file, do not add `set -e`, `set -u`, or `set -o pipefail` globally. Those options leak into the caller's interactive shell and can break unrelated commands. Use strict mode in standalone scripts, or scope options inside a function/subshell.
- Preserve the file's existing portability and startup-cost constraints. Do not add eager subprocesses to files sourced on every shell startup without a measured reason and a guarded/lazy design.

## 2. Prevent arithmetic errors

The most important rule: arithmetic contexts are for known integers only. In Bash, values used in arithmetic can be recursively interpreted as expressions. A variable containing `/opt/podman/...`, an empty string, a path with spaces, or shell syntax can therefore produce an arithmetic parse error or unexpected behavior.

Never put arbitrary text in these forms:

```bash
(( $value ))             # bad: reparses the value as arithmetic
$(( $value + 1 ))        # bad: same problem
let "value = $input"    # bad: input becomes an expression
(( path ))               # bad if path came from the environment or a command
```

Use the operation that matches the data:

```bash
# Text or paths: string tests
if [[ -n "${PODMAN_SOCKET:-}" ]]; then
    printf 'socket: %s\n' "$PODMAN_SOCKET"
fi

# Boolean configuration: explicit string comparison
if [[ ${FEATURE_ENABLED:-0} == 1 ]]; then
    run_feature
fi

# Counts: keep the variable numeric and initialize it locally
local warning_count=0
(( warning_count++ ))
if (( warning_count > 0 )); then
    report_warnings
fi
```

If external input is intended to be numeric, validate it as text before converting it. Reject empty and non-decimal values; do not use arithmetic as the validator:

```bash
local input=${1-}
if [[ ! $input =~ ^[0-9]+$ ]]; then
    printf 'error: expected a non-negative integer\n' >&2
    return 2
fi
local count=$((10#$input))
```

Use `[[ ... == ... ]]` for strings, `[[ -n ... ]]`/`[[ -z ... ]]` for presence, and `(( ... ))` only for variables whose values are created and controlled as integers. Be especially suspicious of `(( $ENV_VAR ))`, `declare -i`, `local -i`, `typeset -i`, and `[[ ... -eq ... ]]` when their operands originate outside the function.

When diagnosing an error such as `bad math expression: operand expected at '/opt/podman...'`:

1. Search the failing file and its callers for `((`, `$((`, `let`, integer declarations, and numeric `[[ ]]` operators.
2. Trace the load path with a clean shell and a useful trace prefix, for example:
   `PS4='+${BASH_SOURCE}:${LINENO}: '; bash -x -c 'source ./config.sh'`.
3. Identify the exact value entering arithmetic; do not print secrets. Report its type/length or a safely redacted prefix if needed.
4. Replace numeric-looking checks on paths/flags with string checks, or validate and convert external numeric input before arithmetic.
5. Re-run with the exact failing value, including an empty value and a path containing spaces.

Do not “fix” this class of bug by merely adding quotes inside `(( ))`; quoting does not turn arbitrary text into a safe integer.

## 3. Expansion and quoting rules

- Quote every parameter expansion unless it is deliberately inside `[[ ]]`, `(( ))`, or an explicitly documented array operation: `"$value"`, `"${array[@]}"`, `"$@"`.
- Use arrays for command arguments. Never construct a command in a string and `eval` it.
- Use `command -- "$path"` where the command supports `--`, so a path beginning with `-` is not treated as an option.
- Use `$(command)` rather than backticks, and quote the complete substitution: `result="$(command)"`.
- Do not use unquoted command substitutions or variables in `source`, redirections, `cd`, `rm`, or command arguments.
- Use `printf '%s\n' "$value"`, not `echo`, for data that may begin with `-`, contain backslashes, or be interpreted differently across platforms.
- Use `[[ ]]` for conditions. It avoids word splitting and pathname expansion, and supports string operators safely.
- Use `local name; name="$(command)"` when the command's exit status matters. `local name="$(command)"` returns the status of `local`, masking the substitution's failure.
- Do not use `eval` unless there is no direct alternative. If unavoidable, explain the trust boundary and prove the constructed input cannot contain shell syntax.

## 4. Functions, status, and failures

- Use `local` for function state and declare variables separately from command substitutions when checking failures.
- Return meaningful non-zero statuses from helpers; callers should use `if helper; then` or `helper || return`.
- Check `cd`, file creation, command substitution, and cleanup when their failure changes behavior.
- In executable scripts, prefer:

  ```bash
  #!/usr/bin/env bash
  set -Eeuo pipefail
  ```

  Add an `ERR` trap only when it improves the diagnostic and does not expose secrets. Remember that `set -e` has exceptions and is not a substitute for explicit error handling.

- In sourced configuration, use guarded feature detection and local functions instead of assuming every command or directory exists.
- Preserve caller state when a helper temporarily changes directory or shell options: use a subshell or save/restore the state.
- Avoid pipelines when a loop or process substitution preserves the needed exit status and avoids a subshell. If a pipeline is necessary, test its failure behavior with `pipefail` enabled in the script.

## 5. Paths, files, and external commands

- Paths are opaque strings. Never split them on whitespace, parse `ls`, or use them as arithmetic.
- Use `[[ -e "$path" ]]`, `[[ -f "$path" ]]`, and `[[ -d "$path" ]]` before operations whose absence is expected.
- Iterate over arrays or null-delimited records. Do not use `for item in $(find ...)`.
- For filenames from a command, prefer `find ... -print0` with `while IFS= read -r -d '' path`; preserve newlines and spaces.
- Resolve a command only when needed, and check availability with `command -v tool >/dev/null 2>&1` in Bash. Do not use zsh's `(($ + commands[tool] ))` in Bash.
- Keep startup configuration cheap: guard optional tools, defer machine queries, and avoid command substitutions in unconditional exports unless the value is required.
- Use `--` for user-controlled filenames and never pass untrusted text through `sh -c`.
- Use temporary files created with `mktemp`, clean them with a trap, and avoid predictable filenames.

## 6. Testing workflow

Run the smallest applicable checks, then test behavior in a clean and adversarial environment. Never assume a syntax check proves a sourced file is safe.

### Syntax and static checks

For a standalone Bash script:

```bash
bash -n path/to/script
```

For a Bash file that is normally sourced, syntax-check it without executing it when possible, then test the real source path in a subshell:

```bash
bash -n path/to/config.sh
bash -c 'source "$1"' bash "$PWD/path/to/config.sh"
```

Use ShellCheck when available:

```bash
shellcheck --shell=bash path/to/script path/to/config.sh
```

If ShellCheck is unavailable, say so; do not claim static analysis passed. Do not install dependencies merely to validate a small change without approval.

For a zsh file, use zsh checks instead of Bash checks:

```bash
zsh -n config/zsh/exports.sh
zsh -f -c 'source ./config/zsh/exports.sh'
```

The `-f` test avoids user startup files. Supply only the minimum required environment and stub optional commands when testing configuration behavior.

### Behavioral matrix

At minimum, exercise values that commonly break shell code:

- variable unset and set to an empty string;
- a normal value and a value containing spaces;
- `/opt/podman/bin/podman` or another path-like value;
- a value beginning with `-`;
- wildcard characters (`*`, `?`, `[`) and a newline;
- numeric input `0`, `1`, a leading-zero value, and invalid text;
- missing optional commands and missing files;
- command failures and interrupted/empty command output.

For configuration files, test twice in the same clean shell when sourcing should be idempotent. Verify that exports, functions, hooks, arrays, and aliases are not duplicated and that optional tools do not create startup errors.

Use an isolated environment for startup tests so the test does not depend on the developer's machine:

```bash
env -i HOME="$HOME" PATH="$PATH" TERM="${TERM:-xterm-256color}" \
    bash --noprofile --norc -c 'source ./config.sh'
```

For a file containing zsh-only syntax, use the equivalent `env -i zsh -f -c` invocation. If the file intentionally depends on a variable, set it explicitly in the test rather than inheriting the whole environment.

When testing a fix for an expansion bug, include the original failing value in a focused regression test. Assert both the exit status and the relevant output/error behavior. A test that only checks `bash -n` will not catch a runtime arithmetic expansion.

Do not run destructive commands, mutate production data, or launch a full suite/build just to validate a local shell change. Prefer a temporary directory and stubs that record arguments. Never print tokens, credentials, or complete sensitive environments while tracing.

## 7. Final review checklist

Before finishing a Bash change, verify:

- The interpreter and invocation mode are known and match the syntax.
- No path, environment string, command output, or user input reaches arithmetic without validation.
- All command arguments and `"$@"` are quoted; arrays are used for argument lists.
- Command failures, `cd`, temporary files, and optional dependencies have deliberate handling.
- Sourceable configuration does not leak strict options or run unnecessary startup subprocesses.
- `bash -n` and the relevant clean-shell source test pass; ShellCheck results are reported honestly.
- The regression case includes unset, empty, path-like, whitespace, and invalid numeric values where relevant.
- The final report names the changed paths, exact checks run, shell/version assumptions, and any skipped validation.
