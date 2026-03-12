_worktree() {
  local state
  _arguments \
    '1: :->subcommand' \
    '*: :->args' && return

  case $state in
    subcommand)
      local -a cmds=(
        'add:create a worktree for a branch'
        'list:list all worktrees with fzf picker'
        'ls:list all worktrees with fzf picker'
        'remove:remove a worktree'
        'rm:remove a worktree'
        'cd:print path to a worktree'
        'clean:remove all worktrees for current repo'
        'mux:pick a worktree and open/attach tmux session'
        'overview:show worktrees with session status and git info'
      )
      _describe 'command' cmds
      ;;
    args)
      case $line[1] in
        add)
          (( $+commands[git] )) && {
            if (( CURRENT == 2 )); then
              local -a branches
              branches=($(git branch --format='%(refname:short)' 2>/dev/null))
              branches+=($(git branch -r --format='%(refname:short)' 2>/dev/null | sed 's|^origin/||'))
              _values 'branch' $branches
            elif (( CURRENT == 3 )); then
              local -a branches
              branches=($(git branch --format='%(refname:short)' 2>/dev/null))
              branches+=($(git branch -r --format='%(refname:short)' 2>/dev/null | sed 's|^origin/||'))
              _values 'base ref' $branches
            fi
          }
          ;;
        remove|rm|cd)
          (( $+commands[git] )) && {
            local -a wt_branches
            wt_branches=($(git worktree list 2>/dev/null | sed -n 's/.*\[\(.*\)\]/\1/p'))
            _values 'branch' $wt_branches
          }
          ;;
      esac
      ;;
  esac
}
compdef _worktree worktree
