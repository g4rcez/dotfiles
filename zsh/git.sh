#############################################################################################################################
## Functions
autoload -Uz is-at-least
git_version="${${(As: :)$(git version 2>/dev/null)}[3]}"

function _git_log_prettily(){
    if ! [ -z $1 ]; then
        git log --pretty="$1"
    fi
}

compdef _git _git_log_prettily=git-log

function git_main_branch() {
    command git rev-parse --git-dir &>/dev/null || return
    local ref
    for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}; do
        if command git show-ref -q --verify $ref; then
            echo "${ref:t}"
            return
        fi
    done
    echo "master"
}

function git_develop_branch() {
    command git rev-parse --git-dir &>/dev/null || return
    local branch
    for branch in dev devel development; do
        if command git show-ref -q --verify refs/heads/$branch; then
            echo "$branch"
            return
        fi
    done
    echo develop
}

function getBranchFzf() {
    git branch --sort=-committerdate | sed 's/* //g' | sed 's/  //g'| grep -v $(git branch --show-current) | fzf --ansi --info inline --preview "echo Branch: {};echo; git log -n 20 --oneline {}" | tr -d ';'
}

function countCommits() {
    gh pr view --json commits | jq '.commits|length' | tr -d "\n"
}

unset git_version

#############################################################################################################################
## alias
alias pushf="git push --force-with-lease"
alias add='git add'
alias checkout='git switch'
alias gcb='git checkout -b'
alias gcd='git checkout $(git_develop_branch)'
alias gcf='git config --list'
alias gcm='git checkout $(git_main_branch)'
alias gd='git diff'
alias gitree='git log --oneline --graph --decorate --all'
alias gitree='git-graph'
alias gittree='git-graph'
alias gst='git status'
alias logs='forgit::log'
alias pull='git pull'
alias push='git push -u'
alias rebase='git rebase'
alias tags='git tag | sort -V'
function gtv() {
    git for-each-ref --sort=creatordate --format '%(creatordate:iso) -> %(refname:short)' refs/tags | grep --color=never '.'
}
#############################################################################################################################
## github-cli
alias ghc='gh pr checkout'
alias ghl='gh pr list'
alias gdash="gh dash"
#############################################################################################################################
## git functions
function gco() {
  _fzf_git_each_ref --no-multi | xargs git checkout
}

function clone() {
  git clone "git@github.com:$1"
}

function wip() {
  git add -A .;
  NOW=$(date +"%Y-%m-%dT%H:%M:%S TZ%Z(%a, %j)");
  git commit --no-verify -S -m "wip: checkpoint at $NOW";
  git push;
}

function pullb() {
    git fetch;
    git pull --rebase origin "$(git branch --show-current)";
}

PRS_TMP_FILE="/tmp/fzf-gitcli"
function parseprs() { 
    if [[ "$(jq length $PRS_TMP_FILE)" == 0 ]]; then
        echo "No pull requests available"
        return;
    fi
    jq -c '.[] | .title' "$PRS_TMP_FILE"\
        | fzf --ansi --info inline\
        --preview "jq -c -r '.[] | select(.title | contains(\"{}\"))|.body' /tmp/fzf-gitcli | sed 's/\\n/\'$'\n''/g' | sed 's/\\r/''/g'" \
        --bind "enter:become(jq -c -r '.[] | select(.title | contains(\"{}\")) | .number' /tmp/fzf-gitcli | xargs -n 1 gh pr checkout)"
}

function prs() {
    gh pr list --json 'body,number,id,title' > $PRS_TMP_FILE
    parseprs
}

function myprs() {
    gh pr list --author "@me" --json 'body,number,id,title' > $PRS_TMP_FILE
    parseprs
}

function killbranches() {
    git for-each-ref --format '%(refname:short)' refs/heads | grep -v "master\|main\|develop" | xargs git branch -D
}

function tag() {
    git tag "$1" && git push origin "$1"
}

function actionWith() {
    git fetch
    local CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    local TARGET_BRANCH="$2"
    git switch "$TARGET_BRANCH"
    git pull origin "$TARGET_BRANCH"
    git switch "$CURRENT_BRANCH"
    git $1 "$TARGET_BRANCH"
}

function mergewith() {
    actionWith "merge" $1
}

function rebasewith() {
    actionWith "rebase" $1
}

function squash() {
  git rebase -i "HEAD~${1}"
}

# squash branch commits based in N commits of current pull request
function squashbranch() {
    COMMITS=$(test -z "$1" && echo $(countCommits) || echo "$1")
    echo "Rebase '$COMMITS' behind...Press ENTER to continue"
    read
    squash "$COMMITS"
}

function switch() {
    BRANCH_TARGET=$(test -z "$1" && echo $(getBranchFzf) || echo "$1")
    git switch "$BRANCH_TARGET";
}

function gitignore() {
  forgit::ignore >> ".gitignore"
}

function git-graph() {
  git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset" --abbrev-commit --all
}

function commit () {
    if [[ "$1" == "" ]]; then
        git commit -S
    else
        git commit -S -m "$1"
    fi
}

function lastcommit() {
    git log --pretty='format:%s 🕑 %cr' 'HEAD^..HEAD' | head -n 1
}

function gtag() {
    git for-each-ref --sort=creatordate --format '%(refname:short)' refs/tags | tac | fzf --preview 'bash $HOME/dotfiles/bin/git-fzf-preview.sh tag {}'
}

#############################################################################################################################
## github functions
function createpr() {
    BRANCH_TARGET=$(test -z "$1" && echo $(getBranchFzf) || echo "$1")
    gh pr create --base "$BRANCH_TARGET" -a "@me" ${@:2}
}

function newpr() {
    createpr "$1"
}

function draft() {
    createpr "$1" "--draft"
}

function ghaction() {
    gh workflow run "${1}.yml" --ref "${2}"
}

