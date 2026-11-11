export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix"
export FZF_ALT_C_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -type d -printf '%P\n' 2>/dev/null"
export FZF_ALT_C_OPTS="--preview 'lsd --tree --depth=2 {}'"
export FZF_CTRL_T_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -printf '%P\n' 2>/dev/null"
export FORGIT_FZF_DEFAULT_OPTS="--ansi --exact --border --cycle --reverse --height '99%' --preview-window right,70%"
export FZF_COMPLETION_TRIGGER="**"

export FZF_DEFAULT_OPTS="--ansi
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-f:preview-up'
--bind 'ctrl-u:preview-down'
--bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)'
--border
$FZF_COLORS
--height 99%
--info=inline
--layout=reverse
--preview '$DOTFILES/bin/lessfilter.sh {}'
--preview-window right,75%
-i
"

function _fzf_comprun() {
    local command=$1
    shift
    case "$command" in
    cd) fzf "$@" --preview 'tree -C {} | head -200' ;;
    *) fzf "$@" --preview "$DOTFILES/bin/lessfilter.sh {}" ;;
    esac
}

function _fzf_git_fzf() {
    fzf-tmux \
        --ansi \
        --bind 'ctrl-/:toggle-preview' \
        --bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)' \
        --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' \
        $FZF_COLORS --color=dark \
        --height '95%' \
        --info=inline \
        -i -l --layout=reverse --multi --height=90% --min-height=30 \
        --preview "$DOTFILES/bin/lessfilter.sh {}" \
        --preview-window 'right,80%' \
        -p99%,99% \
        "$@"
}

export FZF_CTRL_R_OPTS="
--preview 'echo {}' --preview-window up:3:hidden:wrap
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--color header:italic
$FZF_COLORS --color=dark
--height '95%'
--header 'Press CTRL-Y to copy command into clipboard'"

function fcd() {
    cd "$(find . -type d -print | fzf)"
}

function fzf-eval() {
    echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

function view() {
    fd --type f --strip-cwd-prefix | fzf
}

function cdf() {
    DIR="$(fd --type directory --hidden --exclude .git | fzf)"
    cd "$PWD/$DIR"
}

function files() {
    local file="$(fzf --multi)"
    if [[ -n "$file" ]]; then
        local prog
        while IFS= read -r prog; do
            [[ -n "$prog" ]] && "$EDITOR" "$prog"
        done <<<"$file"
    else
        print -r -- "cancelled fzf"
    fi
}

# Preview below the list, full width, no outer border. Delta draws the diff without boxes
# or panel separators. Tracked files show `git diff HEAD`; untracked files show the content.
_ST_PREVIEW='f={-1}
if [ -d "$f" ]; then lsd -l "$f"
elif git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then
    git diff HEAD --color=always -- "$f" | delta --side-by-side -w "${FZF_PREVIEW_COLUMNS:-120}" \
        --hunk-header-decoration-style=none \
        --line-numbers-left-format="{nm:>4} " --line-numbers-right-format="{np:>4} "
else bat --color=always --style=numbers --paging=never -- "$f"; fi'

function st() {
    git rev-parse --git-dir >/dev/null 2>&1 || { echo "You are not in a git repository" && return; }
    local selected
    selected=$(git -c color.status=always status --short |
        fzf --cycle "$@" -m --ansi --nth 2..,.. \
            --border=none --no-scrollbar \
            --preview-window 'down,75%,border-top,nowrap' \
            --preview-label-pos 2 \
            --bind 'focus:transform-preview-label:printf " %s " {-1}' \
            --bind 'ctrl-d:preview-half-page-down' \
            --bind 'ctrl-u:preview-half-page-up' \
            --preview "$_ST_PREVIEW" |
        cut -c4- | sed 's/.* -> //')
    if [[ -n "$selected" ]]; then
        local prog
        while IFS= read -r prog; do
            [[ -n "$prog" ]] && "$EDITOR" "$prog"
        done <<<"$selected"
    fi
}

function _fzf_compgen_path() {
    bfs -H "$1" -color -exclude \( -name .git \) 2>/dev/null
}

function _fzf_compgen_dir() {
    bfs -H "$1" -color -exclude \( -name .git \) -type d 2>/dev/null
}
