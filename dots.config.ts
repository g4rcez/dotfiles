import { defineConfig, espanso } from '@g4rcez/bunsen'

export default defineConfig({
  symlinks: {

    },
  env: {
    shells: ['zsh'],
    exportFile: '~/.config/bunsen/env.sh',
    variables: {
      EDITOR: 'nvim',
      VISUAL: 'nvim',
    },
  },
  espanso: espanso({
    outputPath: '~/.config/espanso/match/base.yml',
    matches: [{ trigger: ':shrug', replace: '¯\\_(ツ)_/¯' }],
  }),
});
