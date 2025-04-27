return {
  { "folke/tokyonight.nvim", priority = 1000 },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup {
        flavour = "mocha",
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = true, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = { comments = { "italic" }, conditionals = { "italic" } },
        default_integrations = true,
        integrations = {
          aerial = true,
          alpha = true,
          barbar = true,
          blink_cmp = true,
          cmp = true,
          colorful_winsep = { enabled = true, color = "lavender" },
          dap = true,
          dap_ui = true,
          gitsigns = true,
          illuminate = true,
          indent_blankline = true,
          markdown = true,
          mason = true,
          mini = { enabled = true, indentscope_color = "" },
          native_lsp = { enabled = true },
          neotree = true,
          notify = true,
          nvimtree = true,
          semantic_tokens = true,
          symbols_outline = true,
          telescope = true,
          treesitter = true,
          ts_rainbow = false,
          ufo = true,
          which_key = true,
          window_picker = true,
        },
      }
      vim.cmd.colorscheme "catppuccin-mocha"
    end,
  },
}
