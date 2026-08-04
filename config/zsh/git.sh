#############################################################################################################################
## Functions
autoload -Uz is-at-least

function _git_require_repo() {
    if ! command git rev-parse --show-toplevel >/dev/null 2>&1; then
        print -u2 -r -- "git helper: not inside a Git worktree"
        return 1
    fi
}

if [[ -n "${NVIM:-}" ]] && (($+commands[nvr])); then
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
    git for-each-ref --sort=creatordate --format '%(creatordate:iso) -> %(refname:short)' refs/tags | command grep '.'
}
#############################################################################################################################
## github-cli
alias ghc='gh pr checkout'
alias ghl='gh pr list'
alias gdash="gh dash"
#############################################################################################################################
## git functions
function gco() {
    local selected
    selected="$(_fzf_git_each_ref --no-multi)" || return $?
    [[ -n "$selected" ]] || return 0
    command git switch "$selected"
}

function git.clone() {
    (($# == 1)) || { print -u2 -r -- "Usage: git.clone OWNER/REPOSITORY"; return 2; }
    command git clone "git@github.com:$1"
}

function commit.wip() {
    emulate -L zsh
    _git_require_repo || return
    command git add -A . || return $?
    local now
    now="$(date +"%Y-%m-%dT%H:%M:%S TZ%Z(%a, %j)")" || return $?
    command git commit --no-verify -S -m "wip: ${now}"
    command git push
}

function _commit_message() {
    emulate -L zsh
    (($# == 1)) || { print -u2 -r -- "git helper: commit message is required"; return 2; }
    _git_require_repo || return
    command git add -A . || return $?
    command git commit -S -m "$1"
    command git push
}

function commitwithai() {
    emulate -L zsh
    _git_require_repo || return
    local -a EXCLUDE_ARGS=()
    local COMMIT_MESSAGE=""
    for f in "${AICOMMIT_EXCLUDES[@]}"; do
        [[ -n "$f" ]] && EXCLUDE_ARGS+=(":(exclude)$f")
    done

    local HINT="${*}"
    local PROMPT
    [[ -r "$DOTFILES/prompts/aicommit-script.txt" ]] || {
        print -u2 -r -- "commitwithai: prompt file not found"
        return 1
    }
    PROMPT="$(<"$DOTFILES/prompts/aicommit-script.txt")"
    if [[ -n "$HINT" ]]; then
        PROMPT="${PROMPT}\n\nContext Hint (use this to explain the WHY): ${HINT}"
    fi

    local DIFF
    DIFF="$(command git diff HEAD -U5 -- . "${EXCLUDE_ARGS[@]}")" || return $?

    if [[ "${AI_CLI_NAME:-}" == "codex" || "${AI_QUERY_COMMAND:-}" == codex* ]]; then
        (($+commands[codex])) || { print -u2 -r -- "commitwithai: codex is not installed"; return 1; }
        local OUT_FILE ERR_FILE RC
        OUT_FILE="$(command mktemp "${TMPDIR:-/tmp}/commitwithai.XXXXXX")" || return $?
        ERR_FILE="$(command mktemp "${TMPDIR:-/tmp}/commitwithai.err.XXXXXX")"
        local mktemp_rc=$?
        if ((mktemp_rc != 0)); then
            command rm -f -- "$OUT_FILE"
            return "$mktemp_rc"
        fi
        printf '%s\n\n%s\n' "$PROMPT" "$DIFF" \
            | command codex -m "${AI_CLI_MODEL:-gpt-5.3-codex-spark}" exec --ignore-user-config --ephemeral --sandbox read-only --output-last-message "$OUT_FILE" - >/dev/null 2>"$ERR_FILE"
        RC=$?
        if (( RC != 0 )); then
            command cat "$ERR_FILE" >&2
            command rm -f -- "$OUT_FILE" "$ERR_FILE"
            return "$RC"
        fi
        COMMIT_MESSAGE="$(<"$OUT_FILE")"
        command rm -f -- "$OUT_FILE" "$ERR_FILE"
    elif [[ "${AI_CLI_NAME:-}" == "pi" || "${AI_QUERY_COMMAND:-}" == pi\ * ]]; then
        # Pi's Responses API provider needs a single explicit user message; do
        # not split the diff into stdin and the instructions into argv.
        local REQUEST="${PROMPT}"$'\n\n'"${DIFF}"
        if ! COMMIT_MESSAGE=$(
            ${=AI_QUERY_COMMAND} --no-tools --no-extensions --no-skills --no-context-files "$REQUEST"
        ); then
            print -u2 -r -- "commitwithai: AI query failed"
            return 1
        fi
    else
        if ! COMMIT_MESSAGE=$(printf '%s\n' "$DIFF" | ${=AI_QUERY_COMMAND} "$PROMPT" | sed 's/# //1'); then
            print -u2 -r -- "commitwithai: AI query failed"
            return 1
        fi
    fi

    COMMIT_MESSAGE="$(printf '%s\n' "$COMMIT_MESSAGE" | awk '
        /^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: / { found = 1 }
        found && /^\[[^]]+ [0-9a-f]{7,}\] / { next }
        found && /^(\/var\/folders\/.*\/T\/tmp\.|\/tmp\/tmp\.)/ { next }
        found { print }
    ' | sed 's/# //1')"

    if [[ -z "$COMMIT_MESSAGE" ]] || ! printf '%s\n' "$COMMIT_MESSAGE" | head -n 1 | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: .+'; then
        print -u2 -r -- "commitwithai: AI did not return a valid Conventional Commit message"
        return 1
    fi

    if (($+commands[pbcopy])); then
        print -rn -- "$COMMIT_MESSAGE" | command pbcopy
    fi
    print -r -- "$COMMIT_MESSAGE"
}

function commit.lockfile() {
    _commit_message "chore: sync lockfile"
}

function commit.deps() {
    _commit_message "chore: update dependencies"
}

function commit.format() {
    _commit_message "style: format source files"
}

function commit.merge() {
    _commit_message "chore: resolve merge conflicts"
}

function commit.cleanup() {
    _commit_message "chore: clean up unused files"
}

function commit.refactor() {
    _commit_message "refactor: code clean up"
}

function commit.remove() {
    _commit_message "chore: remove obsolete files"
}

function commit.rename() {
    _commit_message "refactor: rename files and symbols"
}

function commit.docs() {
    _commit_message "docs: update documentation"
}

function commit.test() {
    _commit_message "test: update tests"
}

function commit.ci() {
    _commit_message "ci: update CI configuration"
}

function commit.release() {
    _commit_message "build: prepare release"
}

function commit.rebase() {
    _commit_message "chore: resolve rebase conflicts"
}

function commit.write() {
    commitwithai "$@"
}

function commit.ai() {
    emulate -L zsh
    _git_require_repo || return
    command git add -A . || return $?
    local commit_message
    commit_message="$(commitwithai "$@")" || return $?
    [[ -n "$commit_message" ]] || { print -u2 -r -- "wip: work in progress"; return 1; }
    command git commit --no-verify -S -m "$commit_message"
    command git push
}

function wip.staged() {
    emulate -L zsh
    _git_require_repo || return
    local now
    now="$(date +"%Y-%m-%dT%H:%M:%S TZ%Z(%a, %j)")" || return $?
    command git commit --no-verify -S -m "wip: ${now}"
}

function pullb() {
    emulate -L zsh
    _git_require_repo || return
    local branch
    branch="$(command git branch --show-current)" || return $?
    [[ -n "$branch" ]] || { print -u2 -r -- "pullb: detached HEAD"; return 1; }
    command git fetch || return $?
    command git pull --rebase origin "$branch"
}

function parseprs() {
    emulate -L zsh
    local prs_tmp_file="${1:-}"
    [[ -r "$prs_tmp_file" ]] || { print -u2 -r -- "parseprs: JSON file is required"; return 2; }

    if [[ "$(jq length "$prs_tmp_file")" == 0 ]]; then
        print -r -- "No pull requests available"
        return 0
    fi
    local selected
    selected="$(jq -r '.[] | "#\(.number) \(.title)"' "$prs_tmp_file" | fzf --ansi --info inline)" || return $?
    [[ -n "$selected" ]] || return 0
    local pr_number="${selected%% *}"
    pr_number="${pr_number#\#}"
    [[ "$pr_number" =~ '^[0-9]+$' ]] || { print -u2 -r -- "parseprs: invalid pull request selection"; return 2; }
    command gh pr checkout "$pr_number"
        # removed unsafe shell-evaluated preview "PR_NUM=\$(echo {} | cut -d' ' -f1 | tr -d '#'); jq -r \".[] | select(.number == \$PR_NUM) | \\\"#\(.number) \(.title)\\n\\n\(.body)\\\"\" \"\$FZF_GITCLI_FILE\" | sed 's/\\\\n/\\'$'\\n''/g' | sed 's/\\\\r/''/g'" \
}

function _prs() {
    emulate -L zsh
    local prs_tmp_file
    prs_tmp_file="$(command mktemp "${TMPDIR:-/tmp}/fzf-gitcli.XXXXXX")" || return $?

    local result=0
    if command gh pr list "$@" --json 'body,number,id,title' >|"$prs_tmp_file"; then
        parseprs "$prs_tmp_file" || result=$?
    else
        result=$?
    fi

    command rm -f -- "$prs_tmp_file"
    return "$result"
}

function prs() {
    _prs
}

function myprs() {
    _prs --author "@me"
}

function killbranches() {
    emulate -L zsh
    local confirm=0 force=0
    while (($#)); do
        case "$1" in
        --confirm | -y) confirm=1 ;;
        --force) force=1 ;;
        --dry-run) ;;
        -h | --help)
            print -r -- "Usage: killbranches [--dry-run|--confirm] [--force]"
            return 0
            ;;
        *) print -u2 -r -- "killbranches: unknown option: $1"; return 2 ;;
        esac
        shift
    done
    _git_require_repo || return

    local current
    current="$(command git branch --show-current)" || return $?
    local -a branches=()
    local branch
    local branch_output
    branch_output="$(command git for-each-ref --format '%(refname:short)' refs/heads)" || return $?
    while IFS= read -r branch; do
        case "$branch" in
        "" | "$current" | main | master | develop | development | dev | trunk | default) continue ;;
        esac
        branches+=("$branch")
    done <<< "$branch_output"

    if ((${#branches[@]} == 0)); then
        print -r -- "no deletable local branches"
        return 0
    fi
    print -rl -- "${branches[@]}"
    if (( ! confirm )); then
        print -r -- "dry-run; rerun with --confirm to delete these branches"
        return 0
    fi

    local delete_flag=-d
    ((force)) && delete_flag=-D
    for branch in "${branches[@]}"; do
        command git branch "$delete_flag" -- "$branch" || return $?
    done
}

function tag() {
    emulate -L zsh
    (($# == 1)) || { print -u2 -r -- "Usage: tag TAG"; return 2; }
    _git_require_repo || return
    command git tag "$1" || return $?
    print -r -- "created tag $1; push it explicitly with: git push origin $1"
}

function actionWith() {
    emulate -L zsh
    (($# == 2)) || { print -u2 -r -- "Usage: actionWith ACTION TARGET_BRANCH"; return 2; }
    _git_require_repo || return
    local action="$1" target_branch="$2" current_branch
    case "$action" in merge | rebase) ;;
    *) print -u2 -r -- "actionWith: action must be merge or rebase"; return 2 ;;
    esac
    current_branch="$(command git branch --show-current)" || return $?
    [[ -n "$current_branch" ]] || { print -u2 -r -- "actionWith: detached HEAD"; return 1; }
    command git fetch || return $?
    command git switch "$target_branch" || return $?
    if ! command git pull --rebase origin "$target_branch"; then
        command git switch "$current_branch" >/dev/null 2>&1 || true
        return 1
    fi
    command git switch "$current_branch" || return $?
    command git "$action" "$target_branch"
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
    git for-each-ref --sort=creatordate --format '%(refname:short)' refs/tags | tac | fzf --preview "bash $DOTFILES/bin/git-fzf-preview.sh tag {}"
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
    emulate -L zsh
    local tmpfile
    tmpfile="$(command mktemp "${TMPDIR:-/tmp}/gh-workflow.XXXXXX")" || return $?
    if ! command gh workflow list --json id,name,path,state >|"$tmpfile"; then
        command rm -f -- "$tmpfile"
        return 1
    fi

    local selected
    selected="$(jq -r '.[] | .name' "$tmpfile" | fzf --ansi --info inline)"
    local selection_rc=$?
    command rm -f -- "$tmpfile"
    ((selection_rc == 0)) || return "$selection_rc"
    [[ -n "$selected" ]] || return 0
    if (($+commands[pbcopy])); then
        print -rn -- "$selected" | command pbcopy
    fi
    print -r -- "$selected"
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
    emulate -L zsh
    (($# == 1)) || { print -u2 -r -- "Usage: gcb BRANCH_NAME"; return 2; }
    _git_require_repo || return
    if command git show-ref --verify --quiet "refs/heads/$1"; then
        command git switch "$1"
    else
        command git switch -c "$1"
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
    emulate -L zsh
    _git_require_repo || return
    local b
    b="$(command git branch --show-current)" || return $?
    print -r -- "$b"
    (($+commands[pbcopy])) && print -rn -- "$b" | command pbcopy
}

function prcommits() {
    emulate -L zsh
    (($# >= 1 && $# <= 2)) || { print -u2 -r -- "Usage: prcommits PR_NUMBER [author_filter]"; return 2; }
    local pr="$1" author="${2:-}"
    [[ "$pr" =~ '^[0-9]+$' ]] || { print -u2 -r -- "prcommits: PR number must be numeric"; return 2; }
    (($+commands[gh])) || { print -u2 -r -- "prcommits: gh is not installed"; return 1; }

    local repo
    repo="$(command gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" || {
        print -u2 -r -- "prcommits: could not determine repo (not in a GitHub repo?)"
        return 1
    }

    local commits
    commits="$(command gh api "repos/${repo}/pulls/${pr}/commits" --paginate --slurp)" || return $?
    if [[ -n "$author" ]]; then
        local author_lower="${author:l}"
        print -r -- "$commits" | jq -r --arg author "$author_lower" '
            [.[][]] | .[]
            | select(
                ((.author.login // "") | ascii_downcase | contains($author)) or
                ((.commit.author.name // "") | ascii_downcase | contains($author))
            )
            | "\(.sha[0:7])  \(.commit.author.date[0:10])  \(.commit.author.name) (\(.author.login // "?")):  \(.commit.message | split("\n")[0])"
        '
    else
        print -r -- "$commits" | jq -r '
            [.[][]] | .[]
            | "\(.sha[0:7])  \(.commit.author.date[0:10])  \(.commit.author.name) (\(.author.login // "?")):  \(.commit.message | split("\n")[0])"
        '
    fi
}

