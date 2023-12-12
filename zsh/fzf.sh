export FORGIT_FZF_DEFAULT_OPTS="--ansi --exact --border --cycle --reverse --height '80%' --preview-window right,50%"
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
-i
--border
--info=inline
--layout=reverse
--height 90%
--color=dark
--color header:italic
--preview '~/dotfiles/bin/lessfilter.sh {}'
--preview-window right,70%
--bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)'
--bind 'ctrl-/:toggle-preview'
--color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#7E8E91,fg:#F8F8F2,header:#7E8E91,info:#f59e0b,pointer:#f59e0b,marker:#6366f1,fg+:#F8F8F2,prompt:#6366f1,hl+:#6366f1 "

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
      --preview '(if [ -d {-1} ];then eza -l --icons {-1}; else git diff --color=always -- {-1} | sed 1,4d; cat {-1}; fi)' |
    cut -c4- | sed 's/.* -> //')
  if [[ $selected ]]; then
    for prog in $(echo $selected); do $EDITOR $prog; done
  fi
}

bindkey "^I" expand-or-complete
bindkey "^[[Z" expand-or-complete
