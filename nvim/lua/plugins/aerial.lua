return {
  {
    "stevearc/aerial.nvim",
    opts = function()
      local opts = {
        attach_mode = "global",
        backends = { "lsp", "treesitter", "markdown", "man" },
        layout = { min_width = 28 },
        show_guides = true,
        filter_kind = false,
        guides = {
          mid_item = "├ ",
          last_item = "└ ",
          nested_top = "│ ",
          whitespace = "  ",
        },
      }
      return opts
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
