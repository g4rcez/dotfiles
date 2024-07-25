local M = {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = function(_, opts)
      opts.options.always_show_bufferline = true
      opts.options.numbers = "ordinal"
      opts.options.separator_style = "slant"
      opts.options.show_buffer_close_icons = true
      opts.options.show_buffer_icons = true
      return opts
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
      require("catppuccin").setup({
        background = { light = "latte", dark = "mocha" }, -- latte, frappe, macchiato, mocha
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        show_end_of_buffer = false, -- show the '~' characters after the end of buffers
        term_colors = true,
        compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
        styles = {
          comments = { "italic" },
          functions = { "bold" },
          keywords = { "italic" },
          operators = { "bold" },
          conditionals = { "bold" },
          loops = { "bold" },
          booleans = { "bold", "italic" },
          numbers = {},
          types = {},
          strings = {},
          variables = {},
          properties = {},
        },
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
          aerial = true,
          alpha = false,
          barbar = false,
          beacon = false,
          cmp = true,
          coc_nvim = false,
          dap = true,
          dap_ui = true,
          dashboard = true,
          dropbar = { enabled = true, color_mode = true },
          fern = true,
          fidget = true,
          flash = true,
          gitgutter = false,
          gitsigns = true,
          harpoon = true,
          headlines = true,
          hop = true,
          illuminate = true,
          indent_blankline = { enabled = true, colored_indent_levels = true },
          leap = true,
          lightspeed = false,
          lsp_saga = true,
          lsp_trouble = true,
          markdown = true,
          mason = true,
          mini = true,
          navic = { enabled = false },
          neogit = false,
          neotest = false,
          neotree = { enabled = false, show_root = true, transparent_panel = false },
          noice = true,
          notify = true,
          nvimtree = true,
          overseer = false,
          pounce = false,
          rainbow_delimiters = true,
          sandwich = false,
          semantic_tokens = true,
          symbols_outline = true,
          telekasten = false,
          telescope = { enabled = true, style = "nvchad" },
          treesitter_context = true,
          ts_rainbow = false,
          vim_sneak = false,
          vimwiki = false,
          which_key = true,
        },
        color_overrides = {},
        highlight_overrides = {
          ---@param cp palette
          all = function(cp)
            return {
              -- For base configs
              NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.mantle },
              FloatBorder = {
                fg = transparent_background and cp.blue or cp.mantle,
                bg = transparent_background and cp.none or cp.mantle,
              },
              CursorLineNr = { fg = cp.green },

              -- For native lsp configs
              DiagnosticVirtualTextError = { bg = cp.none },
              DiagnosticVirtualTextWarn = { bg = cp.none },
              DiagnosticVirtualTextInfo = { bg = cp.none },
              DiagnosticVirtualTextHint = { bg = cp.none },
              LspInfoBorder = { link = "FloatBorder" },

              -- For mason.nvim
              MasonNormal = { link = "NormalFloat" },

              -- For indent-blankline
              IblIndent = { fg = cp.surface0 },
              IblScope = { fg = cp.surface2, style = { "bold" } },

              -- For nvim-cmp and wilder.nvim
              Pmenu = { fg = cp.overlay2, bg = cp.base },
              PmenuBorder = { fg = cp.surface1, bg = cp.base },
              PmenuSel = { bg = cp.green, fg = cp.base },
              CmpItemAbbr = { fg = cp.overlay2 },
              CmpItemAbbrMatch = { fg = cp.blue, style = { "bold" } },
              CmpDoc = { link = "NormalFloat" },
              CmpDocBorder = {
                fg = cp.mantle,
                bg = cp.mantle,
              },

              -- For fidget
              FidgetTask = { bg = cp.none, fg = cp.surface2 },
              FidgetTitle = { fg = cp.blue, style = { "bold" } },

              -- For nvim-notify
              NotifyBackground = { bg = cp.base },

              -- For nvim-tree
              NvimTreeRootFolder = { fg = cp.pink },
              NvimTreeIndentMarker = { fg = cp.surface2 },

              -- For trouble.nvim
              TroubleNormal = { bg = cp.base },

              -- For telescope.nvim
              TelescopeMatching = { fg = cp.lavender },
              TelescopeResultsDiffAdd = { fg = cp.green },
              TelescopeResultsDiffChange = { fg = cp.yellow },
              TelescopeResultsDiffDelete = { fg = cp.red },

              -- For glance.nvim
              GlanceWinBarFilename = { fg = cp.subtext1, style = { "bold" } },
              GlanceWinBarFilepath = { fg = cp.subtext0, style = { "italic" } },
              GlanceWinBarTitle = { fg = cp.teal, style = { "bold" } },
              GlanceListCount = { fg = cp.lavender },
              GlanceListFilepath = { link = "Comment" },
              GlanceListFilename = { fg = cp.blue },
              GlanceListMatch = { fg = cp.lavender, style = { "bold" } },
              GlanceFoldIcon = { fg = cp.green },

              -- For nvim-treehopper
              TSNodeKey = {
                fg = cp.peach,
                bg = cp.base,
                style = { "bold", "underline" },
              },

              -- For treesitter
              ["@keyword.return"] = { fg = cp.pink, style = clear },
              ["@error.c"] = { fg = cp.none, style = clear },
              ["@error.cpp"] = { fg = cp.none, style = clear },
            }
          end,
        },
      })
    end,
  },
}

return M
