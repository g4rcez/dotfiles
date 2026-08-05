/**
 * Espanso Configuration Example
 *
 * This example demonstrates how to use the Espanso builder API
 * with helper methods and trigger documentation.
 */

import { defineConfig, createEspansoConfig } from '../src/api/index.ts'

// Create Espanso configuration with builder methods
const espansoConfig = createEspansoConfig(
  {
    trigger: '::',
    snippets: '~/.config/espanso/match/base.yml',
    imports: ['../config/custom.yml'],
  },
  (e) => ({
    matches: [
      // Simple text replacements
      e.insert('date', '{{date}}', 'Current date'),
      e.insert('time', '{{time}}', 'Current time'),
      e.insert('email', 'user@example.com', 'My email address'),

      // Date formatting
      e.format('isodate', 'date', '%Y-%m-%d', 'ISO formatted date'),
      e.format('fulldate', 'date', '%A, %B %d, %Y', 'Full date format'),

      // Shell commands
      e.shell('uuid', 'Generate UUID', 'uuidgen | tr "[:upper:]" "[:lower:]"'),
      e.shell('pwd', 'Current directory', 'pwd'),
      e.shell('gitbranch', 'Current git branch', 'git branch --show-current 2>/dev/null || echo "not a git repo"'),

      // Random choices
      e.random('greeting', ['Hello', 'Hi', 'Hey', 'Greetings'], 'Random greeting'),
      e.random('bye', ['Goodbye', 'Bye', 'See you', 'Take care'], 'Random farewell'),

      // Clipboard integration
      e.clipboard('paste', 'clip', '{{clip}}', 'Paste clipboard content'),

      // Form with shell command
      e.form('calc', '{{result}}', 'echo "{{form}}" | bc', 'Calculator'),
    ],
  })
)

export default defineConfig({
  espanso: {
    ...espansoConfig,
    whichKeyPath: '~/.config/espanso/triggers.json',
  },
})
