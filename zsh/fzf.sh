_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" --preview '~/dotfiles/bin/lessfilter.sh {}' ;;
  esac
}

export FORGIT_FZF_DEFAULT_OPTS="--ansi --exact --border --cycle --reverse --height '80%' --preview-window right,50%"
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
-i
--border
--info=inline
--layout=reverse
--height 95%
--color=dark
--preview '~/dotfiles/bin/lessfilter.sh {}'
--preview-window right,75%
--bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)'
--bind 'ctrl-/:toggle-preview'
--color fg:#D8DEE9,bg:#1a1e24,hl:#A3BE8C,fg+:#D8DEE9,bg+:#3a455b,hl+:#A3BE8C
--color pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#232428,prompt:#81A1C1,marker:#EBCB8B
"

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
    local CONTENT="$(jq -r '.scripts' package.json)"
    local script=$(jq -r '.scripts | keys[] ' package.json | sort -u | fzf --preview="echo '$CONTENT'") && n "$script"
  fi
}

function fzf-update() {
  DIR="$(pwd)"
  cd ~/.fzf && git pull && ./install
  cd "$DIR"
  exec $SHELL -l
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
    fzf --no-height "$@" --border -m --ansi --nth 2..,.. \
      --preview '(if [ -d {-1} ];then lsd -l {-1}; else git diff --color=always -- {-1} | sed 1,4d; cat {-1}; fi)' |
    cut -c4- | sed 's/.* -> //')
  if [[ $selected ]]; then
    for prog in $(echo $selected); do $EDITOR $prog; done
  fi
}

zz() {
  zoxide query -i
}

bindkey "^I" expand-or-complete
bindkey "^[[Z" expand-or-complete

export FZF_COMPLETION_TRIGGER=''
bindkey '^ ' fzf-completion
bindkey '^I' $fzf_default_completion
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --ansi"
FZF_CTRL_T_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -printf '%P\n' 2>/dev/null"
FZF_ALT_C_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -type d -printf '%P\n' 2>/dev/null"

_fzf_compgen_path() {
    bfs -H "$1" -color -exclude \( -name .git \) 2>/dev/null
}

_fzf_compgen_dir() {
    bfs -H "$1" -color -exclude \( -name .git \) -type d 2>/dev/null
}

