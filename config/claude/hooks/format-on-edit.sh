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
EXT="${EXT,,}"

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
    js|jsx|ts|tsx|css|json)
        FILE_DIR="$(dirname "$FILE_PATH")"
        BIOME_ROOT=$(find_biome_root "$FILE_DIR")
        if [[ -n "$BIOME_ROOT" ]]; then
            # Prefer local biome binary
            if [[ -x "$BIOME_ROOT/node_modules/.bin/biome" ]]; then
                BIOME_BIN="$BIOME_ROOT/node_modules/.bin/biome"
            elif command -v biome >/dev/null 2>&1; then
                BIOME_BIN="biome"
            else
                BIOME_BIN=""
            fi
            if [[ -n "$BIOME_BIN" ]]; then
                FORMATTER="biome"
                FORMATTER_CMD=("$BIOME_BIN" "format" "--write" "$FILE_PATH")
            fi
        fi
        # Fallback to prettier
        if [[ -z "$FORMATTER" ]]; then
            if command -v prettier >/dev/null 2>&1; then
                FORMATTER="prettier"
                FORMATTER_CMD=(prettier --write "$FILE_PATH")
            elif command -v npx >/dev/null 2>&1; then
                # Only use npx if prettier is already installed (--no-install)
                if npx --no-install prettier --version >/dev/null 2>&1; then
                    FORMATTER="prettier"
                    FORMATTER_CMD=(npx --no-install prettier --write "$FILE_PATH")
                fi
            fi
        fi
        ;;
    html)
        if command -v prettier >/dev/null 2>&1; then
            FORMATTER="prettier"
            FORMATTER_CMD=(prettier --write "$FILE_PATH")
        elif command -v npx >/dev/null 2>&1; then
            if npx --no-install prettier --version >/dev/null 2>&1; then
                FORMATTER="prettier"
                FORMATTER_CMD=(npx --no-install prettier --write "$FILE_PATH")
            fi
        fi
        ;;
    sh|bash|zsh)
        if command -v shfmt >/dev/null 2>&1; then
            FORMATTER="shfmt"
            FORMATTER_CMD=(shfmt -w "$FILE_PATH")
        fi
        ;;
    lua)
        if command -v stylua >/dev/null 2>&1; then
            FORMATTER="stylua"
            FORMATTER_CMD=(stylua "$FILE_PATH")
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
