_ai() {
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
        'agents:browse or deploy agents in ./<provider>/agents/'
        'guidelines:copy a guideline file to current directory root'
        'skills:copy skill subdirs to ./<provider>/skills/'
        'update:re-sync all tracked projects'
        'list:browse skills and agents with fzf'
        'sessions:switch to a tmux pane running an AI CLI'
      )
      _describe 'command' cmds
      ;;
    args)
      case $line[1] in
        agents)
          if (( $#line == 1 )); then
            local -a sub=(
              'list:browse available agents'
              'copy:deploy an agent to ./<provider>/agents/'
            )
            _describe 'agents subcommand' sub
          elif (( $#line >= 2 )) && [[ $line[2] == copy ]]; then
            local agents=($DOTFILES/.ai/agents/*.md(N))
            _values 'agent' ${agents:t:r}
          fi
          ;;
        skills)
          local skills=($DOTFILES/.ai/skills/*(N/))
          _values 'skill' ${skills:t}
          ;;
        guidelines)
          local guidelines=($DOTFILES/.ai/guidelines/*(N.))
          _values 'guideline' ${guidelines:t}
          ;;
      esac
      ;;
  esac
}
compdef _ai ai
