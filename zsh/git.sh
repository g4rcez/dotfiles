#############################################################################################################################
## Functions
autoload -Uz is-at-least
git_version="${${(As: :)$(git version 2>/dev/null)}[3]}"

function current_branch() {
  git_current_branch
}

# Pretty log messages
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty="$1"
  fi
}
compdef _git _git_log_prettily=git-log
# Warn if the current branch is a WIP
function work_in_progress() {
  command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- "--wip--" && echo "WIP!!"
}

# Check if main exists and use instead of main
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo master
}

# Check for develop and similarly named branches
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return
    fi
  done
  echo develop
}

function pullb() {
  git pull origin "$(git branch --show-current)"
}

function gitignore() {
  forgit::ignore >> ".gitignore"
}

function git-graph() {
  git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset" --abbrev-commit --all
}

# Clone only with pathname of repository
function clone() {
  git clone "git@github.com:$1"
}

# Create and push a tag
function tag() {
  git tag "$1" && git push origin "$1"
}

# rebase your current branch with the $1 branch
function rebasewith() {
  local CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  local BRANCH="$1"
  git switch "$BRANCH"
  git pull origin "$BRANCH"
  git switch "$CURRENT_BRANCH"
  git rebase "$BRANCH"
}

function squash() {
  git rebase -i "HEAD~${1}"
}

# squash branch commits based in N commits of current pull request
function squashbranch() {
  COMMITS=$(gh pr view --json commits | jq '.commits|length' | tr -d "\n")
  echo "Rebase $COMMITS behind...Press ENTER to continue"
  read
  squash "$COMMITS"
}

unset git_version

#############################################################################################################################
## alias
alias pushf="git push --force-with-lease"
alias add='git add'
alias checkout='git checkout'
alias commit='git commit -S -m'
alias gcb='git checkout -b'
alias gcd='git checkout $(git_develop_branch)'
alias gcf='git config --list'
alias gcm='git checkout $(git_main_branch)'
alias gd='git diff'
alias gitree='git log --oneline --graph --decorate --all'
alias gitree='git-graph'
alias gittree='git-graph'
alias gst='git status'
alias gtv='git tag | sort -V'
alias logs='forgit::log'
alias pull='git pull'
alias push='git push -u'
alias rebase='git rebase'
alias tags='git tag | sort -V'
alias wip='git add . && git commit -S -m "wip: work in progress" && git push'

#############################################################################################################################
## github-cli
alias ghc='gh pr checkout'
alias ghl='gh pr list'
alias prs='gh pr list'
alias pullrequest='gh pr create'
alias gdash="gh dash"

#############################################################################################################################
## fzf git
unalias gco
function gco() {
  _fzf_git_each_ref --no-multi | xargs git checkout
}
