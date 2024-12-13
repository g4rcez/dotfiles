return {
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {} },
  {
    "brenoprata10/nvim-highlight-colors",
    config = function()
      require("nvim-highlight-colors").setup({
        render = "background",
        virtual_symbol = "■",
        virtual_symbol_prefix = "",
        virtual_symbol_suffix = " ",
        virtual_symbol_position = "inline",
        enable_hex = true,
        enable_short_hex = true,
        enable_rgb = true,
        enable_hsl = true,
        enable_var_usage = true,
        enable_named_colors = true,
        enable_tailwind = false,
        exclude_filetypes = {},
        exclude_buftypes = {},
      })
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    lazy = false,
    event = "User FilePost",
    opts = { user_default_options = { names = false }, filetypes = { "*", "!lazy" } },
    config = function(_, opts)
      local colorizer = require("colorizer")
      opts.user_default_options = {
        mode = "background",
        css = true,
      }
      colorizer.setup({
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
        sass = { enable = true, parsers = { "css" } },
        virtualtext = "■",
        always_update = "cmp_menu",
      })
      colorizer.attach_to_buffer(0)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.opt.background = "dark"
      vim.cmd("colorscheme catppuccin")
    end,
    opts = {
      flavour = "mocha",
      background = { light = "latte", dark = "mocha" },
      term_colors = true,
      dim_inactive = { enabled = false },
      integrations = {
        aerial = true,
        alpha = true,
        barbar = false,
        cmp = true,
        barbecue = {
          dim_dirname = true,
          bold_basename = true,
          dim_context = false,
          alt_background = false,
        },
        gitsigns = true,
        harpoon = true,
        lsp_saga = true,
        mason = true,
        neotree = true,
        noice = true,
        notify = true,
        nvimtree = true,
        treesitter = true,
        ufo = true,
        which_key = true,
        mini = { enabled = true },
        navic = { enabled = true },
        telescope = { enabled = true, style = "nvchad" },
        indent_blankline = { enabled = true, colored_indent_levels = true },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
          inlay_hints = { background = true },
        },
      },
    },
  },
}
