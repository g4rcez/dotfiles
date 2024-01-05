-- Config
vim.opt.cmdheight = 0         -- more space in the neovim command line for displaying messages
vim.opt.shiftwidth = 2        -- the number of spaces inserted for each indentation
vim.opt.tabstop = 2           -- insert 2 spaces for a tab
vim.opt.relativenumber = true -- relative line numbers
vim.opt.wrap = true           -- wrap lines
vim.opt.smarttab = true
lvim.colorscheme = "habamax"

-- Plugins
lvim.plugins = {
  { "folke/trouble.nvim", cmd = "TroubleToggle" },
  { "lunarvim/colorschemes" },
  { "metakirby5/codi.vim", cmd = "Codi" },
  { "nvim-telescope/telescope-frecency.nvim" },
  { 'MunifTanjim/nui.nvim' },
  { "folke/persistence.nvim", event = "BufReadPre", opts = {} },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup({})
    end,
  },
  {
    "romgrk/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup {
        enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = {     -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          default = {
            'class',
            'function',
            'method',
          },
        },
      }
    end
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { { 'kkharji/sqlite.lua', module = 'sqlite' } },
    config = function()
      require('neoclip').setup()
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "css", "scss", "html", "javascript" }, {
        RGB = true,      -- #RGB hex codes
        RRGGBB = true,   -- #RRGGBB hex codes
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = true,   -- CSS rgb() and rgba() functions
        hsl_fn = true,   -- CSS hsl() and hsla() functions
        css = true,      -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true,   -- Enable all CSS *functions*: rgb_fn, hsl_fn
      })
    end,
  },
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require('symbols-outline').setup()
    end
  },
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup()
    end,
  },
  {
    "ethanholz/nvim-lastplace",
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = {
          "gitcommit", "gitrebase", "svn", "hgcommit",
        },
        lastplace_open_folds = true,
      })
    end,
  },
}

-- Keymaps
lvim.keys.normal_mode["<leader><leader>"] = "<Cmd>Telescope find_files<CR>"

-- Telescope
lvim.builtin.telescope.defaults.layout_config.width = 0.95
lvim.builtin.telescope.defaults.layout_config.height = 0.8
lvim.builtin.telescope.defaults.layout_config.preview_cutoff = 75
lvim.builtin.telescope.defaults.layout_strategy = "horizontal"
lvim.builtin.telescope.defaults.sorting_strategy = "ascending"
lvim.builtin.telescope.defaults.border = true;
lvim.builtin.telescope.on_config_done = function(telescope)
  pcall(telescope.load_extension, "frecency")
  pcall(telescope.load_extension, "neoclip")
end

local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,

    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,

    ["<C-b>"] = actions.results_scrolling_up,
    ["<C-f>"] = actions.results_scrolling_down,

    ["<C-c>"] = actions.close,

    ["<Down>"] = actions.move_selection_next,
    ["<Up>"] = actions.move_selection_previous,

    ["<CR>"] = actions.select_default,
    ["<C-s>"] = actions.select_horizontal,
    ["<C-v>"] = actions.select_vertical,
    ["<C-t>"] = actions.select_tab,

    ["<c-d>"] = require("telescope.actions").delete_buffer,

    -- ["<C-u>"] = actions.preview_scrolling_up,
    -- ["<C-d>"] = actions.preview_scrolling_down,

    -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
    ["<Tab>"] = actions.close,
    ["<S-Tab>"] = actions.close,
    -- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
    ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
    ["<C-l>"] = actions.complete_tag,
    ["<C-h>"] = actions.which_key, -- keys from pressing <C-h>
    ["<esc>"] = actions.close,
  },
  -- for normal mode
  n = {
    ["<esc>"] = actions.close,
    ["<CR>"] = actions.select_default,
    ["<C-x>"] = actions.select_horizontal,
    ["<C-v>"] = actions.select_vertical,
    ["<C-t>"] = actions.select_tab,
    ["<C-b>"] = actions.results_scrolling_up,
    ["<C-f>"] = actions.results_scrolling_down,

    ["<Tab>"] = actions.close,
    ["<S-Tab>"] = actions.close,
    -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
    -- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
    ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
    ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

    ["j"] = actions.move_selection_next,
    ["k"] = actions.move_selection_previous,
    ["H"] = actions.move_to_top,
    ["M"] = actions.move_to_middle,
    ["L"] = actions.move_to_bottom,
    ["q"] = actions.close,
    ["dd"] = require("telescope.actions").delete_buffer,
    ["s"] = actions.select_horizontal,
    ["v"] = actions.select_vertical,
    ["t"] = actions.select_tab,

    ["<Down>"] = actions.move_selection_next,
    ["<Up>"] = actions.move_selection_previous,
    ["gg"] = actions.move_to_top,
    ["G"] = actions.move_to_bottom,

    ["<C-u>"] = actions.preview_scrolling_up,
    ["<C-d>"] = actions.preview_scrolling_down,

    ["<PageUp>"] = actions.results_scrolling_up,
    ["<PageDown>"] = actions.results_scrolling_down,

    ["?"] = actions.which_key,
  },
}

lvim.builtin.telescope.defaults.selection_caret = "  "

-- Trouble vim
lvim.builtin.which_key.mappings["t"] = {
  name = "Diagnostics",
  t = { "<cmd>TroubleToggle<cr>", "trouble" },
  w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
  d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
  q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
  l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
  r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

-- session manager
lvim.builtin.which_key.mappings["S"] = {
  name = "Session",
  c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
  l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
  Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
}

-- formatters
lvim.format_on_save.enabled = false
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup {
  {
    name = "prettier",
    args = { "--print-width", "120" },
    filetypes = { "typescript", "typescriptreact" },
  },
}

local linters = require("lvim.lsp.null-ls.linters")
linters.setup {
  {
    name = "shellcheck",
    args = { "--severity", "warning" },
  },
}
