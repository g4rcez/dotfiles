/**
 * Espanso Configuration Example
 *
 * This example demonstrates how to use the Espanso builder API
 * with helper methods and trigger documentation.
 */

import { defineConfig, Espanso } from '../src/api/index.ts'

// Create Espanso configuration with builder methods
const espansoConfig = new Espanso('::')
espansoConfig.path = '~/.config/espanso/match/base.yml'
espansoConfig.imports = ['../config/custom.yml']
espansoConfig.insert('date', '{{date}}', 'Current date')
  .insert('time', '{{time}}', 'Current time')
  .insert('email', 'user@example.com', 'My email address')
  .format('isodate', 'date', '%Y-%m-%d', 'ISO formatted date')
  .format('fulldate', 'date', '%A, %B %d, %Y', 'Full date format')
  .shell('uuid', 'Generate UUID', 'uuidgen | tr "[:upper:]" "[:lower:]"')
  .shell('pwd', 'Current directory', 'pwd')
  .shell('gitbranch', 'Current git branch', 'git branch --show-current 2>/dev/null || echo "not a git repo"')
  .random('greeting', ['Hello', 'Hi', 'Hey', 'Greetings'], 'Random greeting')
  .random('bye', ['Goodbye', 'Bye', 'See you', 'Take care'], 'Random farewell')
  .clipboard('paste', 'clip', '{{clip}}', 'Paste clipboard content')
  .form('calc', '{{result}}', 'echo "{{form}}" | bc', 'Calculator')

export default defineConfig({
  espanso: {
    ...espansoConfig,
    whichKeyPath: '~/.config/espanso/triggers.json',
  },
})
