/**
 * Bunsen configuration example with environment variables.
 *
 * Run with: bunsen apply --config examples/karabiner-ts-integrated.config.ts
 */

import { defineConfig } from '../src/api/index.ts'

export default defineConfig({
  env: {
    variables: {
      // EDITOR: 'nvim',
    },
  },
})
