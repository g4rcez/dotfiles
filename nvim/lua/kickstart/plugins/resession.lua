return {
  {
    'rmagatti/auto-session',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('auto-session').setup {
        auto_session_suppress_dirs = {},
        {
          log_level = 'info',
          auto_session_enable_last_session = false,
          auto_session_root_dir = vim.fn.stdpath 'data' .. '/sessions/',
          auto_session_enabled = true,
          auto_save_enabled = nil,
          auto_restore_enabled = nil,
          auto_session_suppress_dirs = nil,
          auto_session_use_git_branch = nil,
          -- the configs below are lua only
          bypass_session_save_file_types = nil,
        },
      }
    end,
  },
  {
    'stevearc/resession.nvim',
    config = function()
      local resession = require 'resession'
      resession.setup {
        autosave = {
          enabled = true,
          interval = 10,
          notify = false,
        },
        options = {
          'binary',
          'bufhidden',
          'buflisted',
          'cmdheight',
          'diff',
          'filetype',
          'modifiable',
          'previewwindow',
          'readonly',
          'scrollbind',
          'winfixheight',
          'winfixwidth',
        },
        -- Custom logic for determining if the buffer should be included
        buf_filter = resession.default_buf_filter,
        -- Custom logic for determining if a buffer should be included in a tab-scoped session
        tab_buf_filter = function(tabpage, bufnr)
          return true
        end,
        -- The name of the directory to store sessions in
        dir = 'session',
        -- Show more detail about the sessions when selecting one to load.
        -- Disable if it causes lag.
        load_detail = true,
        -- List order ["modification_time", "creation_time", "filename"]
        load_order = 'modification_time',
        -- Configuration for extensions
        extensions = {
          quickfix = {},
        },
      }
      vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
          resession.save 'last'
        end,
      })
    end,
  },
}
