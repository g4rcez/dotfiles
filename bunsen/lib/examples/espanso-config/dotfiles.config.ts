/**
 * Espanso Text Expansion Configuration Example
 *
 * This example demonstrates comprehensive Espanso configuration with Bunsen.
 * Includes text replacements, date formatting, shell commands, and forms.
 */
import { defineConfig, espanso } from '../../src/api/index.ts'

export default defineConfig({
  espanso: {
    outputPath: '~/.config/espanso/match/bunsen.yml',
    whichKeyPath: '~/.config/bunsen/espanso-whichkey.json',
    matches: [
      // ====================================================================
      // Basic Text Replacements
      // ====================================================================

      {
        trigger: ':email',
        replace: 'your.email@example.com',
        label: 'Email address',
      },
      {
        trigger: ':gh',
        replace: 'https://github.com/yourusername',
        label: 'GitHub profile',
      },
      {
        trigger: ':phone',
        replace: '+1 (555) 123-4567',
        label: 'Phone number',
      },

      // ====================================================================
      // Greetings & Signatures
      // ====================================================================

      {
        trigger: ':hello',
        replace: 'Hello! How can I help you today?',
        label: 'Friendly greeting',
      },
      {
        trigger: ':thanks',
        replace: 'Thank you for your time and consideration.',
        label: 'Thank you',
      },
      {
        trigger: ':best',
        replace: 'Best regards,\nYour Name',
        label: 'Email signature',
      },

      // ====================================================================
      // Date & Time Variables
      // ====================================================================

      {
        trigger: ':date',
        replace: '{{current_date}}',
        label: 'Current date (YYYY-MM-DD)',
        vars: [
          {
            name: 'current_date',
            type: 'date',
            params: { format: '%Y-%m-%d' },
          },
        ],
      },
      {
        trigger: ':time',
        replace: '{{current_time}}',
        label: 'Current time',
        vars: [
          {
            name: 'current_time',
            type: 'date',
            params: { format: '%H:%M:%S' },
          },
        ],
      },
      {
        trigger: ':datetime',
        replace: '{{datetime}}',
        label: 'Date and time',
        vars: [
          {
            name: 'datetime',
            type: 'date',
            params: { format: '%Y-%m-%d %H:%M' },
          },
        ],
      },
      {
        trigger: ':today',
        replace: '{{today}}',
        label: 'Today (full format)',
        vars: [
          {
            name: 'today',
            type: 'date',
            params: { format: '%A, %B %d, %Y' },
          },
        ],
      },

      // ====================================================================
      // Shell Command Variables
      // ====================================================================

      {
        trigger: ':gitbranch',
        replace: '{{branch}}',
        label: 'Current git branch',
        vars: [
          {
            name: 'branch',
            type: 'shell',
            params: {
              cmd: 'git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo"',
            },
          },
        ],
      },
      {
        trigger: ':gituser',
        replace: '{{git_user}}',
        label: 'Git username',
        vars: [
          {
            name: 'git_user',
            type: 'shell',
            params: {
              cmd: 'git config user.name',
            },
          },
        ],
      },
      {
        trigger: ':pwd',
        replace: '{{current_dir}}',
        label: 'Current directory',
        vars: [
          {
            name: 'current_dir',
            type: 'shell',
            params: {
              cmd: 'pwd',
            },
          },
        ],
      },
      {
        trigger: ':ip',
        replace: '{{local_ip}}',
        label: 'Local IP address',
        vars: [
          {
            name: 'local_ip',
            type: 'shell',
            params: {
              cmd: 'ipconfig getifaddr en0 || hostname -I | awk \'{print $1}\'',
            },
          },
        ],
      },

      // ====================================================================
      // Code Snippets
      // ====================================================================

      {
        trigger: ':log',
        replace: 'console.log({{clipboard}})',
        label: 'Console log',
        vars: [
          {
            name: 'clipboard',
            type: 'clipboard',
          },
        ],
      },
      {
        trigger: ':fn',
        replace: 'function {{name}}({{params}}) {\n  {{cursor}}\n}',
        label: 'Function template',
        vars: [
          {
            name: 'name',
            type: 'form',
            params: { layout: 'Function name: [[name]]' },
          },
          {
            name: 'params',
            type: 'form',
            params: { layout: 'Parameters: [[params]]' },
          },
        ],
      },
      {
        trigger: ':arrow',
        replace: 'const {{name}} = ({{params}}) => {\n  {{cursor}}\n}',
        label: 'Arrow function',
        vars: [
          {
            name: 'name',
            type: 'form',
            params: { layout: 'Function name: [[name]]' },
          },
          {
            name: 'params',
            type: 'form',
            params: { layout: 'Parameters: [[params]]' },
          },
        ],
      },
      {
        trigger: ':if',
        replace: 'if ({{condition}}) {\n  {{cursor}}\n}',
        label: 'If statement',
        vars: [
          {
            name: 'condition',
            type: 'form',
            params: { layout: 'Condition: [[condition]]' },
          },
        ],
      },
      {
        trigger: ':for',
        replace: 'for (let {{var}} = 0; {{var}} < {{length}}; {{var}}++) {\n  {{cursor}}\n}',
        label: 'For loop',
        vars: [
          {
            name: 'var',
            type: 'form',
            params: { layout: 'Variable: [[var]]', default: 'i' },
          },
          {
            name: 'length',
            type: 'form',
            params: { layout: 'Length: [[length]]' },
          },
        ],
      },

      // ====================================================================
      // TypeScript/React Snippets
      // ====================================================================

      {
        trigger: ':comp',
        replace:
          'export function {{name}}() {\n  return (\n    <div>\n      {{cursor}}\n    </div>\n  )\n}',
        label: 'React component',
        vars: [
          {
            name: 'name',
            type: 'form',
            params: { layout: 'Component name: [[name]]' },
          },
        ],
      },
      {
        trigger: ':use',
        replace: 'const [{{state}}, set{{State}}] = useState({{initial}})',
        label: 'useState hook',
        vars: [
          {
            name: 'state',
            type: 'form',
            params: { layout: 'State name: [[state]]' },
          },
          {
            name: 'State',
            type: 'echo',
            params: { echo: '{{state}}' },
          },
          {
            name: 'initial',
            type: 'form',
            params: { layout: 'Initial value: [[initial]]' },
          },
        ],
      },
      {
        trigger: ':effect',
        replace: 'useEffect(() => {\n  {{cursor}}\n}, [{{deps}}])',
        label: 'useEffect hook',
        vars: [
          {
            name: 'deps',
            type: 'form',
            params: { layout: 'Dependencies: [[deps]]' },
          },
        ],
      },

      // ====================================================================
      // Markdown Templates
      // ====================================================================

      {
        trigger: ':todo',
        replace: '- [ ] {{task}}',
        label: 'TODO item',
        vars: [
          {
            name: 'task',
            type: 'form',
            params: { layout: 'Task: [[task]]' },
          },
        ],
      },
      {
        trigger: ':link',
        replace: '[{{text}}]({{url}})',
        label: 'Markdown link',
        vars: [
          {
            name: 'text',
            type: 'form',
            params: { layout: 'Link text: [[text]]' },
          },
          {
            name: 'url',
            type: 'form',
            params: { layout: 'URL: [[url]]' },
          },
        ],
      },
      {
        trigger: ':img',
        replace: '![{{alt}}]({{url}})',
        label: 'Markdown image',
        vars: [
          {
            name: 'alt',
            type: 'form',
            params: { layout: 'Alt text: [[alt]]' },
          },
          {
            name: 'url',
            type: 'form',
            params: { layout: 'Image URL: [[url]]' },
          },
        ],
      },
      {
        trigger: ':code',
        replace: '```{{lang}}\n{{code}}\n```',
        label: 'Code block',
        vars: [
          {
            name: 'lang',
            type: 'form',
            params: { layout: 'Language: [[lang]]' },
          },
          {
            name: 'code',
            type: 'form',
            params: { layout: 'Code:\n[[code]]', multiline: true },
          },
        ],
      },

      // ====================================================================
      // Git Commit Messages
      // ====================================================================

      {
        trigger: ':feat',
        replace: 'feat: {{message}}',
        label: 'Feature commit',
        vars: [
          {
            name: 'message',
            type: 'form',
            params: { layout: 'Commit message: [[message]]' },
          },
        ],
      },
      {
        trigger: ':fix',
        replace: 'fix: {{message}}',
        label: 'Bugfix commit',
        vars: [
          {
            name: 'message',
            type: 'form',
            params: { layout: 'Commit message: [[message]]' },
          },
        ],
      },
      {
        trigger: ':docs',
        replace: 'docs: {{message}}',
        label: 'Documentation commit',
        vars: [
          {
            name: 'message',
            type: 'form',
            params: { layout: 'Commit message: [[message]]' },
          },
        ],
      },
      {
        trigger: ':refactor',
        replace: 'refactor: {{message}}',
        label: 'Refactor commit',
        vars: [
          {
            name: 'message',
            type: 'form',
            params: { layout: 'Commit message: [[message]]' },
          },
        ],
      },

      // ====================================================================
      // Emoji Shortcuts
      // ====================================================================

      {
        trigger: ':shrug',
        replace: '¯\\_(ツ)_/¯',
        label: 'Shrug emoji',
      },
      {
        trigger: ':tableflip',
        replace: '(╯°□°)╯︵ ┻━┻',
        label: 'Table flip',
      },
      {
        trigger: ':check',
        replace: '✓',
        label: 'Check mark',
      },
      {
        trigger: ':cross',
        replace: '✗',
        label: 'Cross mark',
      },
      {
        trigger: ':arrow',
        replace: '→',
        label: 'Right arrow',
      },

      // ====================================================================
      // Random Choice Examples
      // ====================================================================

      {
        trigger: ':greet',
        replace: '{{greeting}}',
        label: 'Random greeting',
        vars: [
          {
            name: 'greeting',
            type: 'random',
            params: {
              choices: ['Hello!', 'Hi there!', 'Hey!', 'Greetings!', "What's up?"],
            },
          },
        ],
      },

      // ====================================================================
      // Regex Matches (Advanced)
      // ====================================================================

      {
        regex: ':calc\\(([0-9+\\-*/. ]+)\\)',
        replace: '{{result}}',
        label: 'Calculate expression',
        vars: [
          {
            name: 'result',
            type: 'shell',
            params: {
              cmd: 'echo "$1" | bc',
            },
          },
        ],
      },
    ],
  },
})
