-- Vim bindings
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.cmdheight = 1             -- more space in the neovim command line for displaying messages
vim.opt.colorcolumn = "99999"
vim.opt.cursorline = true         -- highlight the current line
vim.opt.relativenumber = true
vim.opt.showmode = true           -- we don't need to see things like -- INSERT -- anymore
vim.opt.spell = true
vim.opt.spelllang = "en"
vim.opt.termguicolors = true -- set term gui colors (most terminals support this)
vim.opt.title = true

-- general
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.autopairs.enable_moveright = true
lvim.builtin.bufferline.active = false
lvim.builtin.dap.active = true
lvim.builtin.nvimtree.active = false
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.terminal.active = true
lvim.colorscheme = "onedark"
lvim.format_on_save = true
lvim.leader = "space"
lvim.log.level = "warn"
lvim.transparent_window = true
lvim.use_icons = true

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.builtin.terminal.open_mapping = "<C-t>"
lvim.keys.normal_mode["<C-e>"] = ":NeoTreeFloatToggle<cr>"
lvim.keys.normal_mode["<C-n>"] = ":FzfLua files<cr>"
lvim.keys.normal_mode["<C-p>"] = ":FzfLua files<cr>"
lvim.keys.normal_mode["<leader>f"] = false
lvim.keys.normal_mode["<space>f"] = false
lvim.keys.normal_mode["<space>f"] = nil
lvim.lsp.buffer_mappings.normal_mode['<leader>f'] = nil
lvim.lsp.buffer_mappings.normal_mode['<space>f'] = nil
lvim.lsp.buffer_mappings.normal_mode['<space>f'] = false
lvim.lsp.buffer_mappings.normal_mode['<leader>f'] = false
lvim.builtin.nvimtree.active = true

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("BufEnter", { pattern = { "*.json", "*.jsonc" }, command = "setlocal wrap" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})

lvim.builtin.treesitter.autotag.enable = true
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.ignore_install = {}
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "css",
  "http",
  "java",
  "javascript",
  "json",
  "lua",
  "python",
  "rust",
  "tsx",
  "typescript",
  "yaml",
}

-- -- make sure server will always be installed even if the server is in skipped_servers list
lvim.lsp.installer.setup.ensure_installed = { "jsonls" }
-- ---@usage disable automatic installation of servers
lvim.lsp.installer.setup.automatic_installation = true

-- Additional Plugins
lvim.plugins = {
  {
    "stevearc/dressing.nvim",
    "folke/tokyonight.nvim",
    "MunifTanjim/nui.nvim",
    "farmergreg/vim-lastplace",
    "fladson/vim-kitty",
    "folke/trouble.nvim",
    "ibhagwan/fzf-lua",
    "marko-cerovac/material.nvim",
    "mg979/vim-visual-multi",
    "nacro90/numb.nvim",
    "norcalli/nvim-colorizer.lua",
    "nvim-tree/nvim-web-devicons",
    "navarasu/onedark.nvim",
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build =
      'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    },
    {
      'EthanJWright/vs-tasks.nvim',
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim'
      },
      config = function()
        require("vstask").setup({
          cache_json_conf = true,  -- don't read the json conf every time a task is ran
          cache_strategy = "last", -- can be "most" or "last" (most used / last used)
          config_dir = ".vscode",  -- directory to look for tasks.json and launch.json
          use_harpoon = true,      -- use harpoon to auto cache terminals
          telescope_keys = {       -- change the telescope bindings used to launch tasks
            vertical = '<C-v>',
            split = '<C-p>',
            tab = '<C-t>',
            current = '<CR>',
          },
          autodetect = { -- auto load scripts
            npm = "on"
          },
          terminal = 'toggleterm',
          term_opts = {
            vertical = {
              direction = "vertical",
              size = "80"
            },
            horizontal = {
              direction = "horizontal",
              size = "10"
            },
            current = {
              direction = "float",
            },
            tab = {
              direction = 'tab',
            }
          }
        })
      end
    },
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      opts = {} -- this is equalent to setup({}) function
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
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        -- you can enable a preset for easier configuration
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
      "folke/trouble.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {}
    },
    {
      "rest-nvim/rest.nvim",
      requires = { "nvim-lua/plenary.nvim" },
      config = function()
        require("rest-nvim").setup({
          -- Open request results in a horizontal split
          result_split_horizontal = true,
          -- Keep the http file buffer above|left when split horizontal|vertical
          result_split_in_place = false,
          -- Skip SSL verification, useful for unknown certificates
          skip_ssl_verification = false,
          -- Encode URL before making request
          encode_url = true,
          -- Highlight request on run
          highlight = {
            enabled = true,
            timeout = 150,
          },
          result = {
            -- toggle showing URL, HTTP info, headers at top the of result window
            show_url = true,
            -- show the generated curl command in case you want to launch
            -- the same request via the terminal (can be verbose)
            show_curl_command = true,
            show_http_info = true,
            show_headers = true,
            -- executables or functions for formatting response body [optional]
            -- set them to false if you want to disable them
            formatters = {
              json = "jq",
              html = function(body)
                return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
              end
            },
          },
          jump_to_request = true,
          env_file = '.env',
          custom_dynamic_variables = {},
          yank_dry_run = true,
        })
      end
    },
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
          popup_border_style = "rounded",
          close_if_last_window = true,
          enable_git_status = true,
          window = {
            width = 40,
            position = "right"
          },
          buffers = {
            follow_current_file = true,
          },
          git_status = {
            window = {
              position = "float"
            }
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
    {
      "ziontee113/icon-picker.nvim",
      config = function()
        require("icon-picker").setup({
          disable_legacy_commands = true
        })
      end,
    }
  }
}

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
  { command = "shellcheck", args = { "--severity", "warning" } },
  { command = "codespell",  filetypes = { "*" }, },
}

local code_actions = require("lvim.lsp.null-ls.code_actions")
code_actions.setup { { command = "proselint" } }

-- colorize hex colors
require 'colorizer'.setup({ '*', }, { RGB = true, RRGGBB = true, names = true, RRGGBBAA = true })

require('numb').setup({
  show_numbers = true,         -- Enable 'number' for the window while peeking
  show_cursorline = true,      -- Enable 'cursorline' for the window while peeking
  hide_relativenumbers = true, -- Enable turning off 'relativenumber' for the window while peeking
  number_only = false,         -- Peek only when the command is only a number instead of when it starts with a number
  centered_peeking = true,     -- Peeked line will be centered relative to window
})

lvim.autocommands = {
  {
    { "ColorScheme" },
    {
      pattern = "*",
      callback = function()
        -- change `Normal` to the group you want to change
        -- and `#ffffff` to the color you want
        -- see `:h nvim_set_hl` for more options
        vim.api.nvim_set_hl(0, "Normal", { bg = "#ffffff", underline = false, bold = true })
      end,
    },
  },
}

require('telescope').setup({
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = false,    -- override the file sorter
      case_mode = "ignore_case",       -- or "ignore_case" or "respect_case"
    }
  }
})

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.del("n", '<leader>f');
vim.keymap.del("n", '<space>f');

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
