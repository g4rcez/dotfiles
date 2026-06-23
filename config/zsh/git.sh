#############################################################################################################################
## Functions
autoload -Uz is-at-least

if [[ -n "$NVIM" ]] && command -v nvr &>/dev/null; then
    export GIT_EDITOR="nvr --remote-tab-wait"
fi

function _git_log_prettily() {
    if ! [ -z "$1" ]; then
        git log --pretty="$1"
    fi
}

compdef _git _git_log_prettily=git-log

function git_main_branch() {
    command git rev-parse --git-dir &>/dev/null || return
    local ref
    for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}; do
        if command git show-ref -q --verify "$ref"; then
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
    local current
    current="$(git branch --show-current)"
    git branch --sort=-committerdate | sed 's/* //g' | sed 's/  //g' | grep -vxF -- "$current" | fzf --ansi --info inline --preview "echo Branch: {};echo; git log -n 20 --oneline {}" | tr -d ';'
}

function countCommits() {
    gh pr view --json commits | jq '.commits|length' | tr -d "\n"
}

#############################################################################################################################
## alias
alias pushf="git push --force-with-lease"
alias add='git add'
alias checkout='git switch'
alias gcd='git checkout $(git_develop_branch)'
alias gcf='git config --list'
alias gcm='git checkout $(git_main_branch)'
alias gitree='git-graph'
alias gittree='git-graph'
alias gst='git status'
function _forgit_lazy_load() {
    [[ -n "${functions[forgit::log]:-}" ]] && return 0
    _zsh_lazy_znap_source "wfxr/forgit"
}

function git.log() {
    _forgit_lazy_load && forgit::log "$@"
}

alias pull='git pull'
alias push='git push -u'
alias rebase='git rebase'
alias tags='git tag | sort -V'
alias gundo='git reset --soft HEAD~1'

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

function git.clone() {
    git clone "git@github.com:$1"
}

function commit.wip() {
    git add -A .
    NOW=$(date +"%Y-%m-%dT%H:%M:%S TZ%Z(%a, %j)")
    git commit --no-verify -S -m "wip: ${NOW}"
    git push
}

function commit.write() {
    commitwithai "$@"
}

function commit.ai() {
    git add -A .
    COMMIT_MESSAGE="$(commitwithai "$*")" || return $?
    git commit --no-verify -S -m "${COMMIT_MESSAGE}"
    git push
}

function wip.staged() {
    NOW=$(date +"%Y-%m-%dT%H:%M:%S TZ%Z(%a, %j)")
    git commit --no-verify -S -m "wip: ${NOW}"
    git push
}

function pullb() {
    git fetch
    git pull --rebase origin "$(git branch --show-current)"
}

PRS_TMP_FILE="/tmp/fzf-gitcli"
function parseprs() {
    if [[ "$(jq length $PRS_TMP_FILE)" == 0 ]]; then
        echo "No pull requests available"
        return
    fi
    jq -r '.[] | "#\(.number) \(.title)"' "$PRS_TMP_FILE" |
        fzf --ansi --info inline --preview "PR_NUM=\$(echo {} | cut -d' ' -f1 | tr -d '#'); jq -r \".[] | select(.number == \$PR_NUM) | \\\"#\(.number) \(.title)\\n\\n\(.body)\\\"\" /tmp/fzf-gitcli | sed 's/\\\\n/\\'$'\\n''/g' | sed 's/\\\\r/''/g'" \
            --bind "enter:become(echo {} | cut -d' ' -f1 | tr -d '#' | xargs -n 1 gh pr checkout)"
}

function prs() {
    gh pr list --json 'body,number,id,title' >$PRS_TMP_FILE
    parseprs
}

function myprs() {
    gh pr list --author "@me" --json 'body,number,id,title' >$PRS_TMP_FILE
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
    git "$1" "$TARGET_BRANCH"
}

function mergewith() {
    actionWith "merge" "$1"
}

function rebasewith() {
    actionWith "rebase" "$1"
}

function squash() {
    git rebase -i "HEAD~${1}"
}

function squashbranch() {
    COMMITS=$(test -z "$1" && echo $(countCommits) || echo "$1")
    echo "Rebase '$COMMITS' behind...Press ENTER to continue"
    read -r
    squash "$COMMITS"
}

function switch() {
    BRANCH_TARGET=$(test -z "$1" && echo $(getBranchFzf) || echo "$1")
    git switch "$BRANCH_TARGET"
}

function gitignore() {
    _forgit_lazy_load && forgit::ignore >>".gitignore"
}

function git.ignore() {
    gitignore
}

function git-graph() {
    git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset" --abbrev-commit --all
}

function fakecommit() {
    GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1" git commit -S -m "$2"
}

function scopecommit() {
    local NO_VERIFY=0
    local POSITIONALS=()

    local usage="Usage: scopecommit [-s] \"type: message\"

Rewrites a conventional commit subject to include the current branch as scope.
  feat: msg  ->  feat(BRANCH): msg

Accepted types: feat, fix, build, chore, ci, docs, style, refactor, perf, test
If the message already contains a scope (e.g. feat(foo): ...) it is left untouched.
When no message is given, opens the git editor without a pre-seeded subject.

Options:
  -s, --skip, --no-verify   skip pre-commit and commit-msg hooks
  -h, --help                show this help"

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -s | --skip | --no-verify) NO_VERIFY=1 ;;
        -h | --help) echo "$usage"; return 0 ;;
        --) shift; POSITIONALS+=("$@"); break ;;
        -*) echo "scopecommit: unknown option: $1" >&2; return 2 ;;
        *) POSITIONALS+=("$1") ;;
        esac
        shift
    done

    if [[ ${#POSITIONALS[@]} -gt 1 ]]; then
        echo "scopecommit: only one message argument is allowed" >&2
        return 2
    fi

    local MSG="${POSITIONALS[0]:-}"

    local BRANCH
    BRANCH="$(command git rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
        echo "scopecommit: cannot resolve branch (detached HEAD?)" >&2
        return 1
    }
    if [[ -z "$BRANCH" || "$BRANCH" == "HEAD" ]]; then
        echo "scopecommit: cannot resolve branch (detached HEAD?)" >&2
        return 1
    fi

    local -a ARGS=(-S)
    [[ $NO_VERIFY -eq 1 ]] && ARGS+=(--no-verify)

    local TYPES_ALT='feat|fix|build|chore|ci|docs|style|refactor|perf|test'
    local MSG_OUT

    if [[ -n "$MSG" ]]; then
        if [[ "$MSG" =~ "^(${TYPES_ALT})\([^\)]+\):" ]]; then
            MSG_OUT="$MSG"
        elif [[ "$MSG" =~ "^(${TYPES_ALT}):[[:space:]]*(.*)" ]]; then
            MSG_OUT="${match[1]}(${BRANCH}): ${match[2]}"
        else
            echo "scopecommit: message must start with one of: feat, fix, build, chore, ci, docs, style, refactor, perf, test" >&2
            return 2
        fi
        command git commit "${ARGS[@]}" -m "$MSG_OUT"
    else
        command git commit "${ARGS[@]}"
    fi
}

_scopecommit() {
    _arguments -s \
        '(-s --skip --no-verify)'{-s,--skip,--no-verify}'[skip pre-commit and commit-msg hooks]' \
        '(-h --help)'{-h,--help}'[show help]' \
        '::commit message (type: msg):'
}
compdef _scopecommit scopecommit

function lastcommit() {
    git log --pretty='format:%s 🕑 %cr' 'HEAD^..HEAD' | head -n 1
}

function gtag() {
    git for-each-ref --sort=creatordate --format '%(refname:short)' refs/tags | tac | fzf --preview 'bash $HOME/dotfiles/bin/git-fzf-preview.sh tag {}'
}

#############################################################################################################################
## github functions
function createpr() {
    BRANCH_TARGET=$(test -z "$1" && echo "$(getBranchFzf)" || echo "$1")
    gh pr create --base "$BRANCH_TARGET" -a "@me" "${@:2}"
}

function newpr() {
    createpr "$1"
}

function draft() {
    createpr "$1" "--draft"
}

function gh.action() {
    gh workflow run "${1}.yml" --ref "${2}"
}

function gh.workflow() {
    local tmpfile="$(mktemp)"
    gh workflow list --json id,name,path,state >"$tmpfile"
    jq -r '.[] | .name' "$tmpfile" |
        fzf --ansi --info inline \
            --preview "$DOTFILES/bin/gh-workflow-previewer {} $tmpfile" --bind "enter:become(echo {} | pbcopy && echo {})"
    rm -f "$tmpfile"
}

function commitwithai {
    local EXCLUDE_ARGS=()
    for f in "${AICOMMIT_EXCLUDES[@]}"; do
        EXCLUDE_ARGS+=(":(exclude)$f")
    done

    local HINT="${*}"
    local PROMPT
    PROMPT="$(<"$DOTFILES/prompts/aicommit-script.txt")"
    if [[ -n "$HINT" ]]; then
        PROMPT="${PROMPT}\n\nContext Hint (use this to explain the WHY): ${HINT}"
    fi

    local DIFF
    DIFF="$(git diff HEAD -U5 -- . "${EXCLUDE_ARGS[@]}")"

    if [[ "${AI_CLI_NAME:-}" == "codex" || "${AI_QUERY_COMMAND:-}" == codex* ]]; then
        local OUT_FILE ERR_FILE RC
        OUT_FILE="$(mktemp)"
        ERR_FILE="$(mktemp)"
        printf '%s\n\n%s\n' "$PROMPT" "$DIFF" \
            | codex -m "${AI_CLI_MODEL:-gpt-5.3-codex-spark}" exec --ignore-user-config --ephemeral --sandbox read-only --output-last-message "$OUT_FILE" - >/dev/null 2>"$ERR_FILE"
        RC=$?
        if (( RC != 0 )); then
            command cat "$ERR_FILE" >&2
            rm -f "$OUT_FILE" "$ERR_FILE"
            return "$RC"
        fi
        COMMIT_MESSAGE="$(<"$OUT_FILE")"
        rm -f "$OUT_FILE" "$ERR_FILE"
    else
        COMMIT_MESSAGE=$(printf '%s\n' "$DIFF" | ${=AI_QUERY_COMMAND} "$PROMPT" | sed 's/# //1')
    fi

    COMMIT_MESSAGE="$(printf '%s\n' "$COMMIT_MESSAGE" | awk '
        /^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: / { found = 1 }
        found && /^\[[^]]+ [0-9a-f]{7,}\] / { next }
        found && /^(\/var\/folders\/.*\/T\/tmp\.|\/tmp\/tmp\.)/ { next }
        found { print }
    ' | sed 's/# //1')"

    if [[ -z "$COMMIT_MESSAGE" ]] || ! printf '%s\n' "$COMMIT_MESSAGE" | head -n 1 | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: .+'; then
        echo "commitwithai: AI did not return a valid Conventional Commit message" >&2
        return 1
    fi

    echo "$COMMIT_MESSAGE" | pbcopy
    echo "$COMMIT_MESSAGE"
}

function prdesc() {
    local pr_ref="${1:-}"
    local -a diff_args=()
    [[ -n "$pr_ref" ]] && diff_args=("$pr_ref")

    local prompt
    prompt="$(<"$DOTFILES/prompts/prdesc-script.txt")"

    local PR_MESSAGE
    PR_MESSAGE=$(gh pr diff "${diff_args[@]}" | ${=AI_QUERY_COMMAND} "${prompt}.\n ${pr_ref}")
    echo "$PR_MESSAGE" | pbcopy
    echo "$PR_MESSAGE"
}

function gcb() {
    if [ -z "$1" ]; then
        echo "Usage: gcb <branch-name>"
        return 1
    fi
    if git show-ref --verify --quiet "refs/heads/$1"; then
        git switch "$1"
    else
        git checkout -b "$1"
    fi
}
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

_git_pr_numbers() {
    (( $+commands[gh] )) || return 1

    local -a prs=()
    local pr
    while IFS= read -r pr; do
        [[ -n "$pr" ]] && prs+=("$pr")
    done < <(gh pr list --json number,title --jq '.[] | "\(.number):#\(.number) \(.title)"' 2>/dev/null)
    _describe 'pull request' prs
}

_git_pr_arg() {
    _arguments \
        '1:pull request:_git_pr_numbers' \
        '2:author filter:'
}

_gh_workflow_files() {
    (( $+commands[gh] )) || return 1

    local -a workflows=()
    local workflow
    while IFS= read -r workflow; do
        [[ -n "$workflow" ]] && workflows+=("$workflow")
    done < <(gh workflow list --json path --jq '.[] | .path | sub("^.github/workflows/"; "") | sub("\\.ya?ml$"; "")' 2>/dev/null)
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
compdef _gcb gcb
compdef _git_branch_arg switch mergewith rebasewith createpr newpr draft
compdef _git_pr_arg prcommits prdesc
compdef _gh_action gh.action
compdef _git add=git-add checkout=git-switch pull=git-pull push=git-push pushf=git-push rebase=git-rebase gcf=git-config gundo=git-reset logs=git-log git-graph=git-log gitree=git-log gittree=git-log tags=git-tag gtv=git-tag

branch() {
    local b
    b=$(git branch --show-current)
    echo "$b"
    echo -n "$b" | pbcopy
}

function prcommits() {
    local pr="${1:?Usage: prcommits <PR_NUMBER> [author_filter]}"
    local author="${2:-}"

    local repo
    repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || {
        echo "prcommits: could not determine repo (not in a GitHub repo?)" >&2
        return 1
    }

    local jq_filter
    if [[ -n "$author" ]]; then
        local author_lower="${author:l}"
        jq_filter=".[] | select(
            ((.author.login // \"\") | ascii_downcase | contains(\"${author_lower}\")) or
            ((.commit.author.name // \"\") | ascii_downcase | contains(\"${author_lower}\"))
        ) | \"\(.sha[0:7])  \(.commit.author.date[0:10])  \(.commit.author.name) (\(.author.login // \"?\")):  \(.commit.message | split(\"\n\")[0])\""
    else
        jq_filter='.[] | "\(.sha[0:7])  \(.commit.author.date[0:10])  \(.commit.author.name) (\(.author.login // "?")):  \(.commit.message | split("\n")[0])"'
    fi

    gh api "repos/${repo}/pulls/${pr}/commits" --paginate --jq "$jq_filter"
}

