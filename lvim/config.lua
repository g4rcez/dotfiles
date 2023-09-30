reload("config.vim")
reload("config.lsp")
reload("config.nvimtree")
reload("config.telescope")
reload("config.keymap")
--------------------------------------------------------------------------------
-- Utility
local function merge(t1, t2)
  local shadow = {}
  for _, v in ipairs(t1) do
    table.insert(shadow, v)
  end
  for _, v in ipairs(t2) do
    table.insert(shadow, v)
  end
  return shadow
end
--
---------------------------------------------------------------------------------
-- imports
local augend = require("dial.augend")
local nvim_lsp = require("lspconfig")
--
---------------------------------------------------------------------------------
-- plugins
local themes = {
  "daltonmenezes/aura-theme",
  "folke/tokyonight.nvim",
  "lunarvim/colorschemes",
  "lunarvim/darkplus.nvim",
  "rebelot/kanagawa.nvim",
  "rose-pine/neovim",
  "tiagovla/tokyodark.nvim",
}

lvim.plugins = merge(themes, {
  "onsails/lspkind-nvim",
  "monaqa/dial.nvim",
  'norcalli/nvim-colorizer.lua',
  "nvim-treesitter/nvim-treesitter-textobjects",
  "nvim-tree/nvim-web-devicons",
  "stevearc/dressing.nvim",
  "farmergreg/vim-lastplace",
  "ibhagwan/fzf-lua",
  { "metakirby5/codi.vim",    cmd = "Codi", },
  { "folke/trouble.nvim",     cmd = "TroubleToggle" },
  { "windwp/nvim-ts-autotag", config = function() require("nvim-ts-autotag").setup() end },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim" }
  },
  { "themaxmarchuk/tailwindcss-colors.nvim", config = require("tailwindcss-colors").setup },
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({ input = { enabled = true } })
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      notify = { enabled = false },
      messages = { enabled = false },
      cmdline = {
        view = "cmdline_popup",
      },
      popupmenu = {
        enabled = true,  -- enables the Noice popupmenu UI
        backend = "nui", -- backend to use to show regular cmdline completions
        kind_icons = {}, -- set to `false` to disable icons
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },
  {
    "romgrk/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 1,   -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = {     -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          default = { 'class', 'function', 'method' },
        }
      })
    end
  },
  {
    "folke/twilight.nvim",
    opts = {
      dimming = {
        alpha = 0.5,         -- amount of dimming
        color = { "Normal", "#ffffff" },
        term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
        inactive = false,    -- when true, other windows will be fully dimmed (unless they contain the same buffer)
      },
      context = 10,          -- amount of lines we will try to show around the current line
      treesitter = true,     -- use treesitter when available for the filetype
      expand = {             -- for treesitter, we we always try to expand to the top-most ancestor with these types
        "function",
        "method",
        "table",
        "if_statement",
      },
      exclude = {},
    }
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "kkharji/sqlite.lua" },
    config = function()
      require("telescope").load_extension("frecency")
    end
  },
})

nvim_lsp["tailwindcss"].setup({
  on_attach = function(_, buffer)
    require("tailwindcss-colors").buf_attach(buffer)
  end
})
---------------------------------------------------------------------------------
-- trouble.nvim config
lvim.builtin.which_key.mappings["t"] = {
  name = "Diagnostics",
  t = { "<cmd>TroubleToggle<cr>", "trouble" },
  w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
  d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
  q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
  l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
  r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

require("notify").setup({ background_colour = "#000000" })


require('colorizer').setup()

require("dial.config").augends:register_group({ -- default augends used when no group name is specified
  default = {
    augend.integer.alias.decimal,               -- nonnegative decimal number (0, 1, 2, 3, ...)
    augend.integer.alias.hex,                   -- nonnegative hex number  (0x01, 0x1a1f, etc.)
    augend.date.alias["%Y/%m/%d"],              -- date (2022/03/01, etc.)
    augend.constant.new {
      elements = { "and", "or" },
      word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
      cyclic = true, -- "or" is incremented into "and".
    },
    augend.constant.new {
      elements = { "&&", "||" },
      word = false,
      cyclic = true,
    },
    augend.hexcolor.new {
      case = "lower",
    },
  },
  mygroup = {
    augend.integer.alias.decimal,
    augend.constant.alias.bool,    -- boolean value (true <-> false)
    augend.date.alias["%m/%d/%Y"], -- date (02/19/2022, etc.)
  }
})
