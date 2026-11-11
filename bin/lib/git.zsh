# Git helpers shared by bin/ family scripts (zsh).

git_require_repo() {
    if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
        print -u2 -r -- "git helper: not inside a Git worktree"
        return 1
    fi
}

# Picks a local branch other than the current one with fzf. Callers source config/zsh/fzf.sh for the shared fzf layout.
git_pick_branch() {
    local current
    current="$(git branch --show-current)"
    git branch --sort=-committerdate | sed 's/* //g' | sed 's/  //g' | grep -vxF -- "$current" | fzf --ansi --preview "echo Branch: {};echo; git log -n 20 --oneline {}" | tr -d ';'
}

# Prints the current branch. Fails on a detached HEAD, so each caller words its own error.
git_current_branch() {
    local branch
    branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || return 1
    [[ -n "$branch" && "$branch" != HEAD ]] || return 1
    print -r -- "$branch"
}
