######################### cd Shortcuts #########################
alias docs="cd $HOME/Documents"
alias documents="cd $HOME/Documents"
alias Documents="cd $HOME/Documents"
alias dotfiles="cd $HOME/dotfiles"
alias downloads="cd $HOME/Downloads"
alias Downloads="cd $HOME/Downloads"
alias tools="cd $HOME/tools"
alias Tools="cd $HOME/tools"
######################### simple alias #########################
alias cp='cp -v'
alias df='df -h'
alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias ls="exa --icons -x --color=always"
alias more='less'
alias mv='mv -v'
alias rm='rm -v'
alias vdir='vdir --color=auto'
alias wtf='pwd'
######################### Clipboard utils #########################
alias pbcopy='xclip -sel clip'
alias pbpaste='xclip -selection clipboard -o'
######################### Git/Github CLI utils #########################
alias add='git add'
alias commit='git commit -m'
alias gittree="git log --oneline --graph --decorate --all"
alias gitree="git log --oneline --graph --decorate --all"
alias push='git push -u'
alias pull='git pull'
alias tags='git tag | sort -V'
alias rebase='git rebase'
alias checkout='git checkout'
alias ghc="gh pr checkout"
alias ghl="gh pr list"
######################### General stuff #########################
alias n="pnpm"
alias vim="lvim"
alias dockerkill="docker kill $(docker ps -q)"
alias docker-prune-volumes="docker volume rm $(docker volume ls -q --filter dangling=true)"
alias bomberman="bombardier"
alias cat="bat -p --pager cat --theme OneHalfDark"
alias ll="ls -l"
alias files="fzf --multi --preview 'bat --style=numbers --color=always --line-range :500 {}'"

if [ -x "$(command -v kitty)" ]; then
  alias icat="kitty +kitten icat"
  kitty + complete setup zsh | source /dev/stdin
fi

if [ -x "$(command -v wezterm)" ]; then
  alias company="nohup wezterm connect company --workspace company > /dev/null 2>&1 &"
fi

if [ -x "$(command -v lvim)" ]; then
  alias vim="lvim"
fi

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_OPTS=' --height 40% --layout=reverse --border --info=inline --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
source "$HOME/dotfiles/scripts/fzf-git"
##################################### Functions #####################################
function memory() {
  ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f MB ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }'
}

function clone() {
  git clone "git@github.com:$1"
}

function tag() {
  git tag "$1" && git push origin "$1"
}

function cdm() {
  mkdir -p "$1"
  cd "$1"
}

function sysinfo() {
  ps -A --sort -rsz -o pid,comm,pmem,pcpu | awk "NR<=15"
}

function node:scripts() {
  cat "$PWD/package.json" | jq .scripts
}

function cpv() {
  rsync -pogbr -hhh --backup-dir="$HOME/.tmp" -e /dev/null --progress "$@"
}

function git-graph() {
  git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset" --abbrev-commit --all
}

function extract() {
  if [ -f "$FILE" ]; then
    case $FILE in
    *.tar.bz2) tar xjf "$FILE" ;;
    *.tar.gz) tar xzf "$FILE" ;;
    *.bz2) bunzip2 "$FILE" ;;
    *.rar) unrar x "$FILE" ;;
    *.gz) gunzip "$FILE" ;;
    *.tar) tar xf "$FILE" ;;
    *.tbz2) tar xjf "$FILE" ;;
    *.tgz) tar xzf "$FILE" ;;
    *.zip) unzip "$FILE" ;;
    *.Z) uncompress "$FILE" ;;
    *.7z) 7z x "$FILE" ;;
    *) echo "'$FILE' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$FILE' is not a valid file"
  fi
}

# dotnet autocomplete
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  # If the completion list is empty, just continue with filename selection
  if [ -z "$completions" ]
  then
    _arguments '*::arguments: _normal'
    return
  fi

  # This is not a variable assignment, don't remove spaces!
  _values = "${(ps:\n:)completions}"
}
