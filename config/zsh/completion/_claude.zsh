_claude() {
  local curcontext="$curcontext" state state_descr line
  typeset -A opt_args

  _arguments -C -s \
    '--add-dir[additional directories to allow tool access to]:directory:_files -/' \
    '--agent[agent for the current session]:agent:' \
    '--agents[JSON object defining custom agents]:json or file:_files' \
    '--allow-dangerously-skip-permissions[enable bypassing permission checks as an option]' \
    '(--allowedTools --allowed-tools)'{--allowedTools,--allowed-tools}'[tools to allow]:tools:' \
    '--append-system-prompt[append to the default system prompt]:prompt:' \
    '--autocompact[auto-compact window size]:size:' \
    '--ax-screen-reader[render screen-reader friendly output]' \
    '(--bg --background)'{--bg,--background}'[start the session in the background]' \
    '--bare[minimal mode]' \
    '--betas[beta headers to include in API requests]:betas:' \
    '--brief[enable SendUserMessage tool]' \
    '--chrome[enable Claude in Chrome integration]' \
    '--cloud[create or attach to a cloud session]::description, session id or url:' \
    '(-c --continue)'{-c,--continue}'[continue the most recent conversation]' \
    '--dangerously-skip-permissions[bypass all permission checks]' \
    '(-d --debug)'{-d,--debug}'[enable debug mode]::filter:' \
    '--debug-file[write debug logs to a file]:path:_files' \
    '--desktop[open in the Claude Desktop app]' \
    '--disable-slash-commands[disable all skills and commands]' \
    '(--disallowedTools --disallowed-tools)'{--disallowedTools,--disallowed-tools}'[tools to deny]:tools:' \
    '--effort[effort level for the session]:level:(low medium high xhigh max)' \
    '--environment[run a cloud session on a self-hosted environment]:environment id:' \
    '--exclude-dynamic-system-prompt-sections[move per-machine sections into the first user message]' \
    '--fallback-model[fallback model when the default is unavailable]:model:' \
    '--file[file resources to download at startup]:file_id\:relative_path:' \
    '--fork-session[create a new session ID when resuming]' \
    '--forward-subagent-text[forward subagent text and thinking blocks]' \
    '--from-pr[resume a session linked to a PR]::pr number, url or search:' \
    '(-h --help)'{-h,--help}'[display help]' \
    '--ide[connect to IDE on startup]' \
    '--include-hook-events[include hook lifecycle events in the output stream]' \
    '--include-partial-messages[include partial message chunks]' \
    '--input-format[input format]:format:(text stream-json)' \
    '--json-schema[JSON Schema for structured output]:schema:' \
    '--max-budget-usd[maximum dollar amount to spend on API calls]:amount:' \
    '--mcp-config[load MCP servers from JSON files or strings]:config:_files' \
    '--model[model for the session]:model:(fable opus sonnet haiku)' \
    '(-n --name)'{-n,--name}'[display name for the session]:name:' \
    '--no-chrome[disable Claude in Chrome integration]' \
    '--no-session-persistence[disable session persistence]' \
    '--output-format[output format]:format:(text json stream-json)' \
    '--permission-mode[permission mode]:mode:(acceptEdits auto bypassPermissions manual dontAsk plan)' \
    '--permission-prompts[who answers permission prompts with --print]:target:(host none)' \
    '--plugin-dir[load a plugin from a directory or .zip]:path:_files' \
    '--plugin-url[fetch a plugin .zip from a URL]:url:' \
    '(-p --print)'{-p,--print}'[print response and exit]' \
    '--prompt-suggestions[enable prompt suggestions]::value:(true false 1 0 yes no on off)' \
    '--remote-control[start a session with Remote Control enabled]::name:' \
    '--remote-control-session-name-prefix[prefix for Remote Control session names]:prefix:' \
    '--replay-user-messages[re-emit user messages from stdin on stdout]' \
    '--restricted[restricted mode]' \
    '(-r --resume)'{-r,--resume}'[resume a conversation]::session id, name or search:' \
    '--safe-mode[start with all customizations disabled]' \
    '--session-id[use a specific session ID]:uuid:' \
    '--setting-sources[setting sources to load]:sources:' \
    '--settings[path or JSON string with additional settings]:file or json:_files' \
    '--strict-mcp-config[only use MCP servers from --mcp-config]' \
    '--system-prompt[system prompt to use]:prompt:' \
    '--system-prompt-snapshot[record the system prompt once per conversation]:mode:(on off)' \
    '--teleport[resume a teleport session]::session:' \
    '--tmux[create a tmux session for the worktree]' \
    '--tools[list of available built-in tools]:tools:' \
    '--verbose[override verbose mode setting]' \
    '(-v --version)'{-v,--version}'[output the version number]' \
    '(-w --worktree)'{-w,--worktree}'[create a new git worktree for the session]::name:' \
    '1: :->command' \
    '*:: :->args' && return

  case $state in
    command)
      local -a cmds=(
        'agents:manage background agents'
        'attach:open a background session in this terminal'
        'auth:manage authentication'
        'auto-mode:inspect or reset auto mode configuration'
        'doctor:check the health of the installation'
        'gateway:run the enterprise auth/telemetry gateway'
        'import:import config from another AI coding agent'
        'install:install the Claude Code native build'
        'logs:print a background session recent terminal output'
        'mcp:configure and manage MCP servers'
        'plugin:manage plugins'
        'plugins:manage plugins'
        'purge:delete a project Claude Code data'
        'respawn:restart a background session'
        'rm:delete a background session'
        'setup-token:set up a long-lived authentication token'
        'stop:stop a background session'
        'kill:stop a background session'
        'ultrareview:run a cloud-hosted multi-agent code review'
        'update:check for updates and install if available'
        'upgrade:check for updates and install if available'
      )
      _describe 'command' cmds
      ;;
    args)
      case $line[1] in
        auth)
          (( CURRENT == 2 )) && _values 'auth command' \
            'login[sign in to your Anthropic account]' \
            'logout[log out from your Anthropic account]' \
            'status[show authentication status]' \
            'help[display help for command]'
          ;;
        mcp)
          (( CURRENT == 2 )) && _values 'mcp command' \
            'add[add an MCP server]' \
            'add-from-claude-desktop[import MCP servers from Claude Desktop]' \
            'add-json[add an MCP server with a JSON string]' \
            'get[get details about an MCP server]' \
            'help[display help for command]' \
            'list[list configured MCP servers]' \
            'login[authenticate with an MCP server]' \
            'logout[clear stored OAuth credentials for an MCP server]' \
            'remove[remove an MCP server]' \
            'reset-project-choices[reset project-scoped server choices]' \
            'serve[start the Claude Code MCP server]'
          ;;
        plugin|plugins)
          (( CURRENT == 2 )) && _values 'plugin command' \
            'configure[show or save plugin options]' \
            'details[show a plugin component inventory]' \
            'disable[disable an enabled plugin]' \
            'enable[enable a disabled plugin]' \
            'eval[run eval cases against a plugin]' \
            'help[display help for command]' \
            'init[scaffold a new plugin]' \
            'install[install a plugin from marketplaces]' \
            'list[list installed plugins]' \
            'marketplace[manage marketplaces]' \
            'prune[remove unneeded auto-installed dependencies]' \
            'tag[create a plugin release git tag]' \
            'test[run a mod tests]' \
            'uninstall[uninstall an installed plugin]' \
            'update[update a plugin to the latest version]' \
            'validate[validate a plugin or marketplace manifest]'
          ;;
        install)
          (( CURRENT == 2 )) && _values 'target' stable latest
          ;;
      esac
      ;;
  esac
}

compdef _claude claude
