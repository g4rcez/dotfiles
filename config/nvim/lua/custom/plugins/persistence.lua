return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {
    dir = vim.fn.stdpath 'state' .. '/sessions/',
    need = 1,
    branch = true, -- use git branch to save session
  },
  keys = function()
    vim.keymap.set('n', '<leader>qs', function()
      require('persistence').load()
    end)
    vim.keymap.set('n', '<leader>qS', function()
      require('persistence').select()
    end, { desc = 'Select persistence session' })
    vim.keymap.set('n', '<leader>ql', function()
      require('persistence').load { last = true }
    end)
    vim.keymap.set('n', '<leader>qd', function()
      require('persistence').stop()
    end)
  end,
}
