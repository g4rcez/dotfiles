return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      local wh = require 'which-key'
      local i = require('nvim-web-devicons').get_icon
      wh.setup { preset = 'classic' }
      wh.add {
        { '<leader>c', group = '[c]ode', icon = i 'gcode' },
        { '<leader>d', group = '[d]ocument', icon = i 'doc' },
        { '<leader>r', group = '[r]ename' },
        { '<leader>s', group = '[s]earch', icon = i 'desktop' },
        { '<leader>f', group = '[f]ind', icon = i 'desktop' },
        { '<leader>w', group = '[w]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>x', group = '[x]trouble/errors' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      }
    end,
  },
}
