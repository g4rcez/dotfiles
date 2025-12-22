function _fzf_comprun() {
    local command=$1
    shift
    case "$command" in
    cd) fzf "$@" --preview 'tree -C {} | head -200' ;;
    *) fzf "$@" --preview '~/dotfiles/bin/lessfilter.sh {}' ;;
    esac
}

export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix"
export FZF_ALT_C_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -type d -printf '%P\n' 2>/dev/null"
export FZF_ALT_C_OPTS="--preview 'lsd --tree --depth=2 {}'"
export FZF_CTRL_T_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -printf '%P\n' 2>/dev/null"
export FORGIT_FZF_DEFAULT_OPTS="--ansi --exact --border --cycle --reverse --height '80%' --preview-window right,50%"
export FZF_COMPLETION_TRIGGER="**"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
--ansi
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-d:preview-up'
--bind 'ctrl-u:preview-down'
--bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)'
--border
$FZF_COLORS
--height 95%
--info=inline
--layout=reverse
--preview '~/dotfiles/bin/lessfilter.sh {}'
--preview-window right,75%
-i
"

function _fzf_git_fzf() {
    fzf-tmux \
        --ansi \
        --bind 'ctrl-/:toggle-preview' \
        --bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)' \
        --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' \
        $FZF_COLORS --color=dark \
        --height '95%' \
        --info=inline \
        -l "90%" \
        --layout=reverse --multi --height=90% --min-height=30 \
        --preview '~/dotfiles/bin/lessfilter.sh {}' \
        --preview-window 'right,75%' \
        -i \
        -p90%,90% \
        "$@"
}

export FZF_CTRL_R_OPTS="
--preview 'echo {}' --preview-window up:3:hidden:wrap
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--color header:italic
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

function fns() {
    if [[ -f package.json ]]; then
        local script=$(jq -r '.scripts | keys[] ' package.json | sort -u | fzf --preview="echo 'Script -> {}\n';grep '{}' package.json | sed 's/^[ ]*//g'")
        if [[ "$script" != "" ]]; then
            n "$script"
        fi
    fi
}

function files() {
    local file="$(fzf --multi --reverse)"
    if [[ "$file" ]]; then
        for prog in $(echo $file); do $EDITOR "$prog"; done
    else
        echo "cancelled fzf"
    fi
}

function st() {
    git rev-parse --git-dir >/dev/null 2>&1 || { echo "You are not in a git repository" && return; }
    local selected
    selected=$(git -c color.status=always status --short |
        fzf --no-height --cycle "$@" --border -m --ansi --nth 2..,.. \
            --preview '(if [ -d {-1} ];then lsd -l {-1}; else git diff --color=always -- {-1} | delta --side-by-side -w "$(tput cols)-45" | sed 1,4d; cat {-1}; fi)' |
        cut -c4- | sed 's/.* -> //')
    if [[ $selected ]]; then
        for prog in $(echo $selected); do $EDITOR $prog; done
    fi
}

function _fzf_compgen_path() {
    bfs -H "$1" -color -exclude \( -name .git \) 2>/dev/null
}

function _fzf_compgen_dir() {
    bfs -H "$1" -color -exclude \( -name .git \) -type d 2>/dev/null
}
