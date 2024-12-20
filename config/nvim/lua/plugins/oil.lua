return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        delete_to_trash = true,
        default_file_explorer = true,
        columns = { "icon", "size", "mtime" },
        view_options = { show_hidden = true, case_insensitive = true },
        use_default_keymaps = false,
        keymaps = {
          ["-"] = "actions.parent",
          ["<C-c>"] = "actions.close",
          ["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
          ["<C-l>"] = "actions.refresh",
          ["<C-o>"] = "actions.preview",
          ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
          ["<CR>"] = "actions.select",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["g."] = "actions.toggle_hidden",
          ["g?"] = "actions.show_help",
          ["g\\"] = "actions.toggle_trash",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["q"] = "actions.close",
          ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
        },
        float = {
          padding = 4,
          max_width = 0,
          max_height = 0,
          border = "rounded",
          win_options = { winblend = 1 },
          preview_split = "auto",
          override = function(conf)
            return conf
          end,
        },
        preview = {
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = 0.9,
          min_height = { 5, 0.1 },
          height = nil,
          border = "rounded",
          win_options = { winblend = 10 },
          update_on_cursor_moved = true,
        },
      })
    end,
  },
  {
    "SirZenith/oil-vcs-status",
    event = "VeryLazy",
    opts = {},
    config = function()
      local status_const = require("oil-vcs-status.constant.status")

      local StatusType = status_const.StatusType

      require("oil-vcs-status").setup({
        status_symbol = {
          [StatusType.Added] = "",
          [StatusType.Copied] = "󰆏",
          [StatusType.Deleted] = "",
          [StatusType.Ignored] = "",
          [StatusType.Modified] = "",
          [StatusType.Renamed] = "",
          [StatusType.TypeChanged] = "󰉺",
          [StatusType.Unmodified] = " ",
          [StatusType.Unmerged] = "",
          [StatusType.Untracked] = "",
          [StatusType.External] = "",

          [StatusType.UpstreamAdded] = "󰈞",
          [StatusType.UpstreamCopied] = "󰈢",
          [StatusType.UpstreamDeleted] = "",
          [StatusType.UpstreamIgnored] = " ",
          [StatusType.UpstreamModified] = "󰏫",
          [StatusType.UpstreamRenamed] = "",
          [StatusType.UpstreamTypeChanged] = "󱧶",
          [StatusType.UpstreamUnmodified] = " ",
          [StatusType.UpstreamUnmerged] = "",
          [StatusType.UpstreamUntracked] = " ",
          [StatusType.UpstreamExternal] = "",
        },
      })
    end,
    dependencies = {
      { "stevearc/oil.nvim", opts = {
        win_options = {
          signcolumn = "yes",
        },
      } },
    },
  },
}

