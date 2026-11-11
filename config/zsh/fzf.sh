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

function cdf() {
    DIR="$(fd --type directory --hidden --exclude .git | fzf)"
    cd "$PWD/$DIR"
}

function _fzf_compgen_path() {
    bfs -H "$1" -color -exclude \( -name .git \) 2>/dev/null
}

function _fzf_compgen_dir() {
    bfs -H "$1" -color -exclude \( -name .git \) -type d 2>/dev/null
}
