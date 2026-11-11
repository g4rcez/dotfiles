function _postcd() {
    [[ "${ZSH_AUTO_DOTENV:-0}" == 1 || "${ZSH_AUTO_DOTENV:-0}" == true ]] || return 0
    [[ -f ".env" ]] && dotenv ".env" && print -r -- "[env loaded: .env]"
    [[ -f ".env.local" ]] && dotenv ".env.local" && print -r -- "[env loaded: .env.local]"
    [[ -f "./src/.env" ]] && dotenv "./src/.env" && print -r -- "[env loaded: src/.env]"
    return 0
}

function _zellij_tab_name_update() {
    if [[ -n $ZELLIJ ]]; then
        bash "$DOTFILES/bin/zellij-sessionx-rename" "" "$(pwd)"
    fi
}

export FZF_COLORS="--color=dark,bg+:#2d353d,border:#1E1E2E,bg:#1A1B26,spinner:#f6c177,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --separator=─ --scrollbar=│ --info=right"

function safeImport() {
    local src="${1}"
    if [[ -e "$src" ]]; then
        source "$src"
    fi
}

safeImport "$DOTFILES/bin/lib/zsh-config.zsh"

function zsh:doctor() {
    emulate -L zsh
    setopt extended_glob null_glob
    local root="$(_zsh_config_root)"
    local missing=0
    local warnings=0
    local entry cmd desc file
    print -r -- "zsh doctor"
    print -r -- "config: $root"
    print -r -- ""
    if [[ ! -d "$root" ]]; then
        print -u2 -r -- "error: config directory not found: $root"
        return 1
    fi
    print -r -- "required startup commands"
    local -a required_tools=(
        "git|plugin and Git helper support"
    )
    for entry in "${required_tools[@]}"; do
        cmd="${entry%%|*}"
        desc="${entry#*|}"
        if (($+commands[$cmd])); then
            print -r -- "  ok   $cmd — $desc"
        else
            print -r -- "  miss $cmd — $desc"
            ((missing++))
        fi
    done
    print -r -- ""
    print -r -- "optional startup commands"
    local -a optional_tools=(
        "mise|mise activate zsh"
        "starship|prompt initialization"
        "gh|GitHub CLI completion"
        "zoxide|directory jumper"
        "direnv|directory environment hook (preferred dotenv workflow)"
        "tv|television shell integration"
        "fzf|fzf shell integration"
        "atuin|history synchronization"
        "zellij|opt-in multiplexer integration"
    )
    for entry in "${optional_tools[@]}"; do
        cmd="${entry%%|*}"
        desc="${entry#*|}"
        if (($+commands[$cmd])); then
            print -r -- "  ok   $cmd — $desc"
        else
            print -r -- "  skip $cmd — $desc"
        fi
    done
    print -r -- ""
    print -r -- "plugin manager"
    local znap_entrypoint="${ZNAP_ENTRYPOINT:-$HOME/.znap/znap.zsh}"
    if [[ -r "$znap_entrypoint" ]]; then
        print -r -- "  ok   znap — plugin manager"
    else
        print -r -- "  warn znap — not installed; run zshx install when plugin support is needed"
        ((warnings++))
    fi
    print -r -- ""
    print -r -- "optional helper commands"
    local -a helper_tools=(
        "bat|cat alias and previews"
        "lsd|ls alias and fzf previews"
        "fd|file pickers"
        "bfs|fzf path generation"
        "jq|JSON helpers"
        "delta|git diff previews"
        "tmux|active multiplexer helpers"
        "vivid|LS_COLORS generation"
        "podman|lazy Docker compatibility host discovery"
        "nvr|Neovim remote git editor inside NVIM"
        "pbcopy|clipboard bindings"
    )
    for entry in "${helper_tools[@]}"; do
        cmd="${entry%%|*}"
        desc="${entry#*|}"
        if (($+commands[$cmd])); then
            print -r -- "  ok   $cmd — $desc"
        else
            print -r -- "  warn $cmd — $desc"
            ((warnings++))
        fi
    done
    print -r -- ""
    print -r -- "sourced files (required)"
    local -a required_sources=(
        "$root/exports.sh"
        "$root/utils.sh"
        "$root/alias.sh"
        "$root/zstyle.sh"
        "$root/history.sh"
    )
    for file in "${required_sources[@]}"; do
        if [[ -f "$file" ]]; then
            print -r -- "  ok   ${file#$root/}"
        else
            print -r -- "  miss ${file#$root/}"
            ((missing++))
        fi
    done
    print -r -- ""
    print -r -- "sourced files (optional integrations)"
    local -a optional_sources=(
        "$root/fzf.sh"
        "$root/git.sh"
        "$root/node.sh"
        "$root/completion/node-completion.sh"
        "$root/completion/_ai.zsh"
        "$root/completion/_worktree.zsh"
        "$root/completion/_family.zsh"
    )
    if [[ -z "$TMUX" ]] && (($+commands[zellij])); then
        optional_sources+=("$root/zellij.sh")
    fi
    for file in "${optional_sources[@]}"; do
        if [[ -f "$file" ]]; then
            print -r -- "  ok   ${file#$root/}"
        else
            print -r -- "  skip ${file#$root/}"
        fi
    done

    print -r -- ""
    print -r -- "completion registration"
    # Znap defers compinit until the first precmd to reduce startup cost. Run
    # that hook for an explicit doctor invocation so non-interactive checks see
    # the same completion state as an interactive prompt.
    local completion_hook
    for completion_hook in "${precmd_functions[@]}"; do
        if [[ "$completion_hook" == ..znap.compinit-hook ]] && (( $+functions[$completion_hook] )); then
            "$completion_hook"
            break
        fi
    done
    unset completion_hook

    local -a completion_entries=(
        "ai|_ai"
        "worktree|_worktree"
        "commit|_family"
    )
    if (($+functions[compdef])); then
        for entry in "${completion_entries[@]}"; do
            cmd="${entry%%|*}"
            desc="${entry#*|}"
            if [[ -n "${functions[$desc]:-}" ]] && (( $+parameters[_comps] )) && [[ "${_comps[$cmd]:-}" == "$desc" ]]; then
                print -r -- "  ok   $cmd → $desc"
            else
                print -u2 -r -- "  miss $cmd → $desc (compinit/registration)"
                ((missing++))
            fi
        done
    else
        print -u2 -r -- "  miss compdef (compinit was not initialized)"
        ((missing++))
    fi

    print -r -- ""
    print -r -- "compiled caches"
    local -a stale=()
    local -a source_files=()
    while IFS= read -r file; do
        source_files+=("$file")
    done < <(_zsh_config_sources "$root")
    for file in "${source_files[@]}"; do
        if [[ -e "$file.zwc" && "$file" -nt "$file.zwc" ]]; then
            stale+=("${file#$root/}")
        fi
    done
    if (($#stale)); then
        print -r -- "  warn stale .zwc files; run zshx compile"
        print -rl -- "${stale[@]/#/       }"
        ((warnings += $#stale))
    else
        print -r -- "  ok   no stale .zwc files"
    fi

    print -r -- ""
    print -r -- "PATH"
    local -A seen
    local -a duplicates=()
    for file in "${path[@]}"; do
        if [[ -n "${seen[$file]:-}" ]]; then
            duplicates+=("$file")
        else
            seen[$file]=1
        fi
    done
    if (($#duplicates)); then
        print -r -- "  warn duplicate PATH entries; run path:dedupe"
        print -rl -- "${duplicates[@]/#/       }"
        ((warnings += $#duplicates))
    else
        print -r -- "  ok   no duplicate PATH entries"
    fi

    print -r -- ""
    print -r -- "summary: $missing missing, $warnings warning(s)"
    return $((missing > 0 ? 1 : 0))
}

function cd:repo() {
    emulate -L zsh

    local root
    root="$(command git rev-parse --show-toplevel 2>/dev/null)" || {
        print -u2 -r -- "cd:repo: not inside a git repository"
        return 1
    }
    builtin cd "$root"
}

function cd:zsh() {
    emulate -L zsh
    builtin cd "$(_zsh_config_root)"
}

function cd:mk() {
    emulate -L zsh

    if [[ $# -ne 1 ]]; then
        print -u2 -r -- "Usage: cd:mk DIR"
        return 2
    fi

    command mkdir -p -- "$1" && builtin cd "$1"
}

function cd:tmp() {
    emulate -L zsh

    local prefix="${1:-zsh}"
    prefix="${prefix//[^A-Za-z0-9_.-]/-}"

    local dir
    dir="$(command mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX")" || return
    builtin cd "$dir"
}

function cd:up() {
    emulate -L zsh

    local levels="${1:-1}"
    if [[ ! "$levels" =~ '^[0-9]+$' ]]; then
        print -u2 -r -- "Usage: cd:up [N]"
        return 2
    fi

    local target="."
    while ((levels-- > 0)); do
        target="../$target"
    done
    builtin cd "$target"
}

function path:list() {
    emulate -L zsh
    print -rl -- $path
}

function path:dedupe() {
    emulate -L zsh

    local before=$#path
    typeset -gU path PATH
    path=("${path[@]}")
    local after=$#path

    print -r -- "PATH: removed $((before - after)) duplicate(s)"
}

function path:has() {
    emulate -L zsh

    if [[ $# -ne 1 ]]; then
        print -u2 -r -- "Usage: path:has DIR"
        return 2
    fi

    local needle="${1:A}"
    local entry
    for entry in $path; do
        if [[ "${entry:A}" == "$needle" ]]; then
            return 0
        fi
    done
    return 1
}

function path:which() {
    emulate -L zsh

    if (($# == 0)); then
        print -u2 -r -- "Usage: path:which CMD [...]"
        return 2
    fi

    local cmd
    for cmd in "$@"; do
        print -r -- "== $cmd =="
        whence -a "$cmd"
    done
}

autoload -Uz add-zsh-hook
add-zsh-hook -d chpwd _postcd 2>/dev/null
add-zsh-hook chpwd _postcd

function _osc7_cwd() {
    printf '\033]7;file://%s%s\033\\' "${HOST:-localhost}" "$PWD"
}
add-zsh-hook -d chpwd _osc7_cwd 2>/dev/null
add-zsh-hook chpwd _osc7_cwd
_osc7_cwd
