#!/usr/bin/env bash
# PostToolUse hook: auto-format files after Edit or Write tool calls.
# Reads the tool result JSON from stdin and formats based on file extension.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Nothing to do if no file path
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Resolve extension (lowercase)
EXT="${FILE_PATH##*.}"
EXT=$(printf '%s' "$EXT" | tr '[:upper:]' '[:lower:]')

# ── Helper: find biome root walking up from a directory ─────────────────────
find_biome_root() {
    local dir="$1"
    while [[ "$dir" != "/" && "$dir" != "." ]]; do
        if [[ -f "$dir/biome.json" || -f "$dir/biome.jsonc" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# ── Helper: resolve a formatter outside project-local dependency bins ────────
resolve_trusted_command() {
    local resolved
    resolved=$(command -v "$1" 2>/dev/null) || return 1
    case "$resolved" in
    */node_modules/.bin/*) return 1 ;;
    esac
    printf '%s\n' "$resolved"
}

# ── Helper: hash file contents ───────────────────────────────────────────────
file_hash() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" 2>/dev/null | awk '{print $1}'
    else
        # Fallback: use mtime+size as a poor-man's hash
        stat -f '%m%z' "$1" 2>/dev/null || stat -c '%Y%s' "$1" 2>/dev/null
    fi
}

# ── Helper: emit a block response ────────────────────────────────────────────
block() {
    local reason="$1"
    local output="$2"
    printf '%s' "$(jq -n --arg reason "$reason" --arg output "$output" \
        '{decision: "block", reason: $reason, hookSpecificOutput: $output}')"
    exit 0
}

# ── Determine formatter ───────────────────────────────────────────────────────
FORMATTER=""
FORMATTER_CMD=()

case "$EXT" in
js | jsx | ts | tsx | css | json)
    FILE_DIR="$(dirname "$FILE_PATH")"
    BIOME_ROOT=$(find_biome_root "$FILE_DIR")
    if [[ -n "$BIOME_ROOT" ]]; then
        BIOME_BIN=$(resolve_trusted_command biome) || BIOME_BIN=""
        if [[ -n "$BIOME_BIN" ]]; then
            FORMATTER="biome"
            FORMATTER_CMD=("$BIOME_BIN" "format" "--write" "$FILE_PATH")
        fi
    fi
    # Fallback to prettier
    if [[ -z "$FORMATTER" ]]; then
        PRETTIER_BIN=$(resolve_trusted_command prettier) || PRETTIER_BIN=""
        if [[ -n "$PRETTIER_BIN" ]]; then
            FORMATTER="prettier"
            FORMATTER_CMD=("$PRETTIER_BIN" --write "$FILE_PATH")
        fi
    fi
    ;;
html)
    PRETTIER_BIN=$(resolve_trusted_command prettier) || PRETTIER_BIN=""
    if [[ -n "$PRETTIER_BIN" ]]; then
        FORMATTER="prettier"
        FORMATTER_CMD=("$PRETTIER_BIN" --write "$FILE_PATH")
    fi
    ;;
sh | bash | zsh)
    SHFMT_BIN=$(resolve_trusted_command shfmt) || SHFMT_BIN=""
    if [[ -n "$SHFMT_BIN" ]]; then
        FORMATTER="shfmt"
        FORMATTER_CMD=("$SHFMT_BIN" -w "$FILE_PATH")
    fi
    ;;
lua)
    STYLUA_BIN=$(resolve_trusted_command stylua) || STYLUA_BIN=""
    if [[ -n "$STYLUA_BIN" ]]; then
        FORMATTER="stylua"
        FORMATTER_CMD=("$STYLUA_BIN" "$FILE_PATH")
    fi
    ;;
esac

# No formatter found or applicable — exit silently
if [[ -z "$FORMATTER" ]]; then
    exit 0
fi

# ── Snapshot hash before formatting ──────────────────────────────────────────
HASH_BEFORE=$(file_hash "$FILE_PATH")

# ── Run formatter ─────────────────────────────────────────────────────────────
FORMAT_OUTPUT=$("${FORMATTER_CMD[@]}" 2>&1)
FORMAT_EXIT=$?

if [[ $FORMAT_EXIT -ne 0 ]]; then
    block "Formatter ($FORMATTER) failed on $FILE_PATH" "$FORMAT_OUTPUT"
fi

# ── Check if file changed ─────────────────────────────────────────────────────
HASH_AFTER=$(file_hash "$FILE_PATH")

if [[ "$HASH_BEFORE" != "$HASH_AFTER" ]]; then
    block "Auto-formatted $FILE_PATH with $FORMATTER" \
        "The file was automatically reformatted by $FORMATTER after your edit."
fi

# No changes — exit silently
exit 0
