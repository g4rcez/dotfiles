#############################################################################################################################
## Functions
autoload -Uz is-at-least

if [[ -n "${NVIM:-}" ]] && (($+commands[nvr])); then
    export GIT_EDITOR="nvr --remote-tab-wait"
fi

function _git_log_prettily() {
    if ! [ -z "$1" ]; then
        git log --pretty="$1"
    fi
}

compdef _git _git_log_prettily=git-log

function _forgit_lazy_load() {
    [[ -n "${functions[forgit::log]:-}" ]] && return 0
    _zsh_lazy_znap_source "wfxr/forgit"
}

function git.log() {
    _forgit_lazy_load && forgit::log "$@"
}

#############################################################################################################################
## alias
alias pushf="git push --force-with-lease"
alias add='git add'
alias checkout='git switch'
alias git.config='git config --list'
alias gitree='gitx graph'
alias gittree='gitx graph'
alias gst='git status'
alias pull='git pull'
alias push='git push -u'
alias rebase='git rebase'
alias tags='git tag | sort -V'
alias gundo='git reset --soft HEAD~1'
alias st='pick status'
#############################################################################################################################
## github-cli
alias ghc='PAGER=less gh pr checkout'
alias ghl='PAGER=less gh pr list'
alias gdash="gh dash"
#############################################################################################################################
## git functions
function gco() {
    local selected
    selected="$(_fzf_git_each_ref --no-multi)" || return $?
    [[ -n "$selected" ]] || return 0
    command git switch "$selected"
}

function gitignore() {
    _forgit_lazy_load && forgit::ignore >>".gitignore"
}

function git.ignore() {
    gitignore
}

#############################################################################################################################
_git_local_and_remote_branches() {
    (( $+commands[git] )) || return 1

    local -a branches=()
    local branch
    while IFS= read -r branch; do
        [[ -n "$branch" ]] && branches+=("$branch")
    done < <(git branch --format='%(refname:short)' 2>/dev/null)
    while IFS= read -r branch; do
        [[ -n "$branch" && "$branch" != HEAD ]] && branches+=("$branch")
    done < <(git branch -r --format='%(refname:short)' 2>/dev/null | sed 's|^origin/||')

    _values 'branch' "${branches[@]}"
}

_git_branch_arg() {
    _arguments '1:branch:_git_local_and_remote_branches'
}

_git_compare_args() {
    _arguments \
        '1:branch:_git_local_and_remote_branches' \
        '2:branch:_git_local_and_remote_branches'
}

_git_restore_args() {
    _arguments \
        '1:branch:_git_local_and_remote_branches' \
        '2:file:_files'
}

typeset -g _git_completion_cache_ttl=30
typeset -g _git_completion_timeout=2
typeset -g _git_pr_numbers_cache=''
typeset -g _git_pr_numbers_cache_at=-1
typeset -g _git_pr_numbers_cache_repo=''
typeset -g _gh_workflow_files_cache=''
typeset -g _gh_workflow_files_cache_at=-1
typeset -g _gh_workflow_files_cache_repo=''

_git_completion_cache_fresh() {
    local cached_at="$1"
    [[ "$cached_at" =~ '^[0-9]+$' ]] || return 1
    (( SECONDS - cached_at < _git_completion_cache_ttl ))
}

_git_completion_gh() {
    local timeout_command=''
    if (($+commands[gtimeout])); then
        timeout_command="${commands[gtimeout]}"
    elif (($+commands[timeout])); then
        timeout_command="${commands[timeout]}"
    fi

    if [[ -n "$timeout_command" ]]; then
        command "$timeout_command" "$_git_completion_timeout" gh "$@"
    else
        command gh "$@"
    fi
}

_git_completion_repository() {
    command git rev-parse --show-toplevel 2>/dev/null
}

_git_pr_numbers() {
    (( $+commands[gh] )) || return 1

    local repository
    repository="$(_git_completion_repository)" || return 1
    if [[ "$repository" != "$_git_pr_numbers_cache_repo" ]]; then
        _git_pr_numbers_cache=''
        _git_pr_numbers_cache_at=-1
        _git_pr_numbers_cache_repo="$repository"
    fi

    local output
    if _git_completion_cache_fresh "$_git_pr_numbers_cache_at"; then
        output="$_git_pr_numbers_cache"
    elif output="$(_git_completion_gh pr list --limit 50 --json number,title --jq '.[] | "\(.number):#\(.number) \(.title)"' 2>/dev/null)"; then
        _git_pr_numbers_cache="$output"
        _git_pr_numbers_cache_at="$SECONDS"
    else
        _git_pr_numbers_cache_at="$SECONDS"
        output="$_git_pr_numbers_cache"
    fi

    local -a prs=()
    local pr
    while IFS= read -r pr; do
        [[ -n "$pr" ]] && prs+=("$pr")
    done <<< "$output"
    _describe 'pull request' prs
}

_git_pr_arg() {
    _arguments \
        '1:pull request:_git_pr_numbers' \
        '2:author filter:'
}

_gh_workflow_files() {
    (( $+commands[gh] )) || return 1

    local repository
    repository="$(_git_completion_repository)" || return 1
    if [[ "$repository" != "$_gh_workflow_files_cache_repo" ]]; then
        _gh_workflow_files_cache=''
        _gh_workflow_files_cache_at=-1
        _gh_workflow_files_cache_repo="$repository"
    fi

    local output
    if _git_completion_cache_fresh "$_gh_workflow_files_cache_at"; then
        output="$_gh_workflow_files_cache"
    elif output="$(_git_completion_gh workflow list --limit 50 --json path --jq '.[] | .path | sub("^.github/workflows/"; "") | sub("\\.ya?ml$"; "")' 2>/dev/null)"; then
        _gh_workflow_files_cache="$output"
        _gh_workflow_files_cache_at="$SECONDS"
    else
        _gh_workflow_files_cache_at="$SECONDS"
        output="$_gh_workflow_files_cache"
    fi

    local -a workflows=()
    local workflow
    while IFS= read -r workflow; do
        [[ -n "$workflow" ]] && workflows+=("$workflow")
    done <<< "$output"
    _values 'workflow' "${workflows[@]}"
}

_gh_action() {
    _arguments \
        '1:workflow:_gh_workflow_files' \
        '2:ref:_git_local_and_remote_branches'
}

_gcb() {
    _git_local_and_remote_branches
}

compdef _git add=git-add checkout=git-switch pull=git-pull push=git-push pushf=git-push rebase=git-rebase gundo=git-reset gitree=git-log gittree=git-log tags=git-tag

