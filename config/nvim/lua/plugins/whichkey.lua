return {
  'folke/which-key.nvim',
  opts = {
      preset = 'helix',
      spec = {
        { '<leader>f', group = '[F]ind' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    }
}
