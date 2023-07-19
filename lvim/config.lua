-- general
lvim.builtin.bufferline.active = false
lvim.colorscheme = "tokyonight-night"
lvim.format_on_save = true
lvim.leader = "space"
lvim.log.level = "warn"
lvim.use_icons = true
vim.opt.relativenumber = true

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.builtin.terminal.open_mapping = "<c-t>"
lvim.keys.normal_mode["<C-e>"] = ":NeoTreeFloatToggle<cr>"
lvim.keys.normal_mode["<C-p>"] = ":FzfLua files<cr>"
lvim.transparent_window = true
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  --   -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
  },
  --   -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.dap.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.active = false
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
--
-- autopairs
lvim.builtin.autopairs.enable_moveright = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = {}
lvim.builtin.treesitter.highlight.enable = true

-- generic LSP settings

-- -- make sure server will always be installed even if the server is in skipped_servers list
lvim.lsp.installer.setup.ensure_installed = {
  "jsonls",
}
--
-- ---@usage disable automatic installation of servers
lvim.lsp.installer.setup.automatic_installation = true


-- Additional Plugins
lvim.plugins = {
  {
    "farmergreg/vim-lastplace",
    "ibhagwan/fzf-lua",
    "folke/trouble.nvim",
    "fladson/vim-kitty",
    "norcalli/nvim-colorizer.lua",
    "nvim-tree/nvim-web-devicons",
    "nacro90/numb.nvim",
    "MunifTanjim/nui.nvim",
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = true,
          window = {
            width = 30,
          },
          buffers = {
            follow_current_file = true,
          },
          filesystem = {
            follow_current_file = true,
            filtered_items = {
              hide_dotfiles = false,
              hide_gitignored = false,
              hide_by_name = {
                "node_modules"
              },
              never_show = {
                ".DS_Store",
                "thumbs.db"
              },
            },
          },
        })
      end
    },
  }
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.json", "*.jsonc" },
  --   -- enable wrap mode for json files only
  command = "setlocal wrap",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})

-- Custom
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.cmdheight = 1             -- more space in the neovim command line for displaying messages
vim.opt.showmode = true           -- we don't need to see things like -- INSERT -- anymore
vim.opt.termguicolors = true      -- set term gui colors (most terminals support this)
vim.opt.cursorline = true         -- highlight the current line
vim.opt.colorcolumn = "99999"
vim.opt.title = true
vim.opt.spell = true
vim.opt.spelllang = "en"

lvim.lsp.installer.setup.automatic_installation = true
lvim.lsp.templates_dir = join_paths(get_runtime_dir(), "after", "ftplugin")
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black" },
  {
    command = "prettier",
    args = { "--print-width", "150" },
    filetypes = { "typescript", "typescriptreact", "javascript" },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "flake8" },
  {
    command = "shellcheck",
    args = { "--severity", "warning" },
  },
  {
    command = "codespell",
    filetypes = { "*" },
  },
}

local code_actions = require "lvim.lsp.null-ls.code_actions"
code_actions.setup {
  {
    command = "proselint"
  },
}

-- colorize hex colors
require 'colorizer'.setup({ '*', }, {
  RGB = true,
  RRGGBB = true,
  names = true,
  RRGGBBAA = true,
})

require('numb').setup({
  show_numbers = true,         -- Enable 'number' for the window while peeking
  show_cursorline = true,      -- Enable 'cursorline' for the window while peeking
  hide_relativenumbers = true, -- Enable turning off 'relativenumber' for the window while peeking
  number_only = false,         -- Peek only when the command is only a number instead of when it starts with a number
  centered_peeking = true,     -- Peeked line will be centered relative to window
})
