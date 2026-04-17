_ai() {
  # Complete --provider value regardless of its position
  if [[ $words[CURRENT-1] == --provider ]]; then
    _values 'provider' claude gemini codex opencode
    return
  fi

  local state
  _arguments \
    '--provider[AI provider]:provider:(claude gemini codex opencode)' \
    '1: :->subcommand' \
    '*: :->args' && return

  case $state in
    subcommand)
      local -a cmds=(
        'agents:copy guidelines to current directory root'
        'subagents:copy agent subdirs to ./<provider>/agents/'
        'skills:copy skill subdirs to ./<provider>/skills/'
        'update:re-sync all tracked projects'
        'list:browse skills and agents with fzf'
        'sessions:switch to a tmux pane running an AI CLI'
      )
      _describe 'command' cmds
      ;;
    args)
      case $line[1] in
        skills)
          local skills=($DOTFILES/.ai/skills/*(N/))
          _values 'skill' ${skills:t}
          ;;
        subagents)
          local agents=($DOTFILES/.ai/agents/*(N/))
          _values 'agent' ${agents:t}
          ;;
        agents)
          local guidelines=($DOTFILES/.ai/guidelines/*(N.))
          _values 'guideline' ${guidelines:t}
          ;;
      esac
      ;;
  esac
}
compdef _ai ai
