# Completion for the bin/ family scripts (bin/lib/family.zsh): subcommands come from `<command> --commands`.
# Arguments after a subcommand use the completer named in _family_completers ("command:subcommand" -> function).
typeset -gA _family_completers=(
    commit:scope _family_commit_scope
    gitx:switch _git_branch_arg
    gitx:new _gcb
    gitx:merge-with _git_branch_arg
    gitx:rebase-with _git_branch_arg
    gitx:compare _git_compare_args
    gitx:restore _git_restore_args
    ghpr:create _git_branch_arg
    ghpr:draft _git_branch_arg
    ghpr:desc _git_pr_arg
    ghpr:commits _git_pr_arg
    ghx:action _gh_action
    proc:kill-port _family_listening_ports
    proc:grep _family_process_names
    proc:ports _family_process_names
    filex:extract _files
    filex:size _files
    filex:copy _files
    rmx:dry-run _files
    rmx:trash _files
    rmx:safe _files
)

_family_commit_scope() {
    _arguments -s \
        '(-s --skip --no-verify)'{-s,--skip,--no-verify}'[skip pre-commit and commit-msg hooks]' \
        '(-h --help)'{-h,--help}'[show help]' \
        '::commit message (type: msg):'
}

_family_listening_ports() {
    local -a ports=()
    local port
    while IFS= read -r port; do
        [[ -n "$port" ]] && ports+=("$port")
    done < <(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR > 1 { n = split($9, a, ":"); if (a[n] ~ /^[0-9]+$/) print a[n] ":" $1 }' | sort -u)
    _describe 'listening port' ports
}

_family_process_names() {
    local -a processes=()
    local process
    while IFS= read -r process; do
        [[ -n "$process" ]] && processes+=("$process:$process")
    done < <(ps -axo comm= 2>/dev/null | sed 's#.*/##' | sort -u)
    _describe 'process' processes
}

_family() {
    local cmd="${words[1]}"
    if ((CURRENT == 2)); then
        local -a subs=("${(@f)$(command "$cmd" --commands 2>/dev/null)}")
        _describe 'command' subs
        return
    fi
    local completer="${_family_completers[${cmd}:${words[2]}]}"
    [[ -n "$completer" ]] || return 1
    shift words
    ((CURRENT--))
    "$completer"
}

compdef _family commit gitx ghpr ghx proc dk rmx filex sys pick nodex zshx
