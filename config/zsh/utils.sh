function checkcommand() {
    if [[ -f "$(command -v $1)" ]]; then
        echo -n
    else
        $2
    fi
}

function _postcd() {
    [[ -f ".env" ]] && dotenv ".env" && echo "[env loaded: .env]"
    [[ -f ".env.local" ]] && dotenv ".env.local" && echo "[env loaded: .env.local]"
    [[ -f "./src/.env" ]] && dotenv "./src/.env" && echo "[env loaded: src/.env]"
}

function isGitDir() {
    echo $(git -C "$1" rev-parse --is-inside-work-tree 2>/dev/null)
}

function getCurrentBranch() {
    echo $(git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null)
}

function getRepositoryName() {
    echo $(git -C "$1" config --get remote.origin.url 2>/dev/null | cut -d ':' -f2- | sed ' s/\.git$//g')
}

function basename2() {
    echo $(basename "$(dirname "$1")")/$(basename "$1")
}

function _zellij_tab_name_update() {
    if [[ -n $ZELLIJ ]]; then
        bash "$DOTFILES/bin/zellij-sessionx-rename" "" "$(pwd)"
    fi
}

function forEach() {
    ARRAY=$(echo "$1" | tr ' ' '\n')
    for item in $ARRAY; do
        "$2" $item
    done
}

function fishify() {
    echo $(echo "$1" | perl -pe '
   BEGIN {
      binmode STDIN,  ":encoding(UTF-8)";
      binmode STDOUT, ":encoding(UTF-8)";
   }; s|^$ENV{HOME}|~|g; s|/([^/.])[^/]*(?=/)|/$1|g; s|/\.([^/])[^/]*(?=/)|/.$1|g
')
}

export FZF_COLORS="--color=dark,bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

function safeImport() {
    if [[ -e "$1" ]]; then
        source "$1"
    fi
}

function clearNvim() {
    rm -rf "$HOME/.cache/nvim"
    rm -rf "$HOME/.local/share/nvim"
    rm -rf "$HOME/.local/state/nvim"
}

function _zsh_config_root() {
    print -r -- "${DOTFILES:-$HOME/dotfiles}/config/zsh"
}

function _zsh_config_sources() {
    emulate -L zsh

    local root="${1:-$(_zsh_config_root)}"

    [[ -f "$root/zshrc" ]] && print -r -- "$root/zshrc"
    command find "$root" -maxdepth 1 -type f \( -name '*.sh' -o -name '*.zsh' \) -print 2>/dev/null | command sort
    if [[ -d "$root/completion" ]]; then
        command find "$root/completion" -maxdepth 1 -type f \( -name '*.sh' -o -name '*.zsh' \) -print 2>/dev/null | command sort
    fi
}

function zsh:help() {
    command cat <<'EOF'
zsh utilities

  zsh:doctor              Check shell dependencies, sourced files, stale .zwc files, and PATH duplicates
  zsh:compile [--clean]   Compile config/zsh shell files to .zwc files; --clean removes orphaned .zwc files
  zsh:profile [N]         Time N interactive shell startups; add --zprof for detailed zprof output
  zsh:edit [query]        Pick a config/zsh file with fzf and open it in $EDITOR

cd utilities

  cd:repo                 cd to the current git repository root
  cd:zsh                  cd to dotfiles/config/zsh
  cd:mk DIR               mkdir -p DIR and cd into it
  cd:tmp [prefix]         Create a temporary directory and cd into it
  cd:up [N]               cd up N directories

PATH utilities

  path:list               Print PATH entries, one per line
  path:dedupe             Remove duplicate PATH entries in the current shell
  path:has DIR            Return success if DIR is in PATH
  path:which CMD [...]    Show every executable/function/alias resolution for command(s)
EOF
}

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

    print -r -- "startup commands"
    local -a startup_tools=(
        "mise|mise activate zsh"
        "git|znap clone/plugin management"
        "starship|prompt initialization"
        "gh|GitHub CLI completion"
        "zoxide|directory jumper"
        "direnv|direnv hook"
        "tv|television shell integration"
        "fzf|fzf shell integration"
    )
    for entry in $startup_tools; do
        cmd="${entry%%|*}"
        desc="${entry#*|}"
        if (($ + commands[$cmd])); then
            print -r -- "  ok   $cmd — $desc"
        else
            print -r -- "  miss $cmd — $desc"
            ((missing++))
        fi
    done

    print -r -- ""
    print -r -- "helper commands"
    local -a helper_tools=(
        "bat|cat alias and previews"
        "lsd|ls alias and fzf previews"
        "fd|file pickers"
        "bfs|fzf path generation"
        "jq|JSON helpers"
        "delta|git diff previews"
        "tmux|active multiplexer helpers"
        "vivid|LS_COLORS generation"
        "podman|docker compatibility alias / DOCKER_HOST"
        "nvr|Neovim remote git editor inside NVIM"
        "pbcopy|clipboard bindings"
    )
    for entry in $helper_tools; do
        cmd="${entry%%|*}"
        desc="${entry#*|}"
        if (($ + commands[$cmd])); then
            print -r -- "  ok   $cmd — $desc"
        else
            print -r -- "  warn $cmd — $desc"
            ((warnings++))
        fi
    done

    print -r -- ""
    print -r -- "sourced files"
    local -a expected_sources=(
        "$root/exports.sh"
        "$root/utils.sh"
        "$root/alias.sh"
        "$root/zstyle.sh"
        "$root/history.sh"
        "$root/fzf.sh"
        "$root/git.sh"
        "$root/node.sh"
        "$root/zellij.sh"
        "$root/completion/node-completion.sh"
        "$root/completion/_ai.zsh"
        "$root/completion/_worktree.zsh"
        "$root/completion/_commit.zsh"
    )
    for file in $expected_sources; do
        if [[ -f "$file" ]]; then
            print -r -- "  ok   ${file#$root/}"
        else
            print -r -- "  miss ${file#$root/}"
            ((missing++))
        fi
    done

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
        print -r -- "  warn stale .zwc files; run zsh:compile"
        print -rl -- "${stale[@]/#/       }"
        ((warnings += $#stale))
    else
        print -r -- "  ok   no stale .zwc files"
    fi

    print -r -- ""
    print -r -- "PATH"
    local -A seen
    local -a duplicates=()
    for file in $path; do
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

function zsh:compile() {
    emulate -L zsh
    setopt null_glob

    local root="$(_zsh_config_root)"
    local clean=0
    local dry_run=0
    local usage="Usage: zsh:compile [--clean] [--dry-run]

Compile config/zsh shell files to adjacent .zwc files.

Options:
  --clean     remove .zwc files whose source file no longer exists
  --dry-run   show what would be compiled/removed without changing files
  -h, --help  show this help"

    while (($#)); do
        case "$1" in
        --clean) clean=1 ;;
        --dry-run | -n) dry_run=1 ;;
        -h | --help)
            print -r -- "$usage"
            return 0
            ;;
        *)
            print -u2 -r -- "zsh:compile: unknown option: $1"
            return 2
            ;;
        esac
        shift
    done

    if [[ ! -d "$root" ]]; then
        print -u2 -r -- "zsh:compile: config directory not found: $root"
        return 1
    fi

    if ((clean)); then
        local zwc src
        while IFS= read -r zwc; do
            src="${zwc%.zwc}"
            if [[ ! -e "$src" ]]; then
                if ((dry_run)); then
                    print -r -- "would remove ${zwc#$root/}"
                else
                    command rm -f -- "$zwc"
                    print -r -- "removed ${zwc#$root/}"
                fi
            fi
        done < <(command find "$root" -type f -name '*.zwc' -print 2>/dev/null)
    fi

    local file failed=0 compiled=0
    local -a source_files=()
    while IFS= read -r file; do
        source_files+=("$file")
    done < <(_zsh_config_sources "$root")
    for file in "${source_files[@]}"; do
        if ((dry_run)); then
            print -r -- "would compile ${file#$root/}"
            continue
        fi

        if zcompile "$file"; then
            print -r -- "compiled ${file#$root/}"
            ((compiled++))
        else
            print -u2 -r -- "failed ${file#$root/}"
            ((failed++))
        fi
    done

    ((dry_run)) && return 0
    print -r -- "compiled $compiled file(s); $failed failure(s)"
    return $failed
}

function zsh:profile() {
    emulate -L zsh

    local runs=3
    local detailed=0
    local usage="Usage: zsh:profile [--zprof] [runs]

Times interactive zsh startup in a child shell. Use --zprof for detailed function profiling."

    while (($#)); do
        case "$1" in
        --zprof | -z) detailed=1 ;;
        -h | --help)
            print -r -- "$usage"
            return 0
            ;;
        *)
            if [[ "$1" =~ '^[0-9]+$' ]]; then
                runs="$1"
            else
                print -u2 -r -- "zsh:profile: unknown argument: $1"
                return 2
            fi
            ;;
        esac
        shift
    done

    local i
    for ((i = 1; i <= runs; i++)); do
        print -r -- "run $i/$runs"
        time zsh -i -c exit
    done

    if ((detailed)); then
        local rc="${ZDOTDIR:-$HOME}/.zshrc"
        [[ -r "$rc" ]] || rc="$(_zsh_config_root)/zshrc"
        print -r -- ""
        print -r -- "zprof: $rc"
        ZSH_PROFILE_RC="$rc" zsh -dfi -c 'zmodload zsh/zprof; source "$ZSH_PROFILE_RC"; zprof'
    fi
}

function zsh:edit() {
    emulate -L zsh
    setopt pipefail

    local root="$(_zsh_config_root)"
    if [[ ! -d "$root" ]]; then
        print -u2 -r -- "zsh:edit: config directory not found: $root"
        return 1
    fi
    if ! (($ + commands[fzf])); then
        print -u2 -r -- "zsh:edit: fzf is required"
        return 1
    fi

    local preview="bat --color=always --style=numbers '$root'/{} 2>/dev/null || command sed -n '1,160p' '$root'/{}"
    local -a fzf_args=(
        --prompt='zsh> '
        --height=90%
        --preview="$preview"
    )
    (($#)) && fzf_args+=(--query="$*")

    local selected
    selected=$(command find "$root" -type f ! -name '*.zwc' -print |
        command sed "s#^$root/##" |
        command sort |
        fzf "${fzf_args[@]}") || return
    [[ -n "$selected" ]] || return 0

    command "${EDITOR:-nvim}" "$root/$selected"
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

chpwd_functions+=(_postcd)

function _osc7_cwd() {
    printf '\033]7;file://%s%s\033\\' "${HOST:-localhost}" "$PWD"
}
chpwd_functions+=(_osc7_cwd)
_osc7_cwd
