local code_actions = require("lvim.lsp.null-ls.code_actions")
local formatters = require("lvim.lsp.null-ls.formatters")
local linters = require "lvim.lsp.null-ls.linters"
local nvim_lsp = require("lspconfig")
local actions = require "telescope.actions"
---------------------------------------------------------------------------------
-- lvim
lvim.leader = "space"
lvim.colorscheme = "onedark"
lvim.builtin.nvimtree.setup.view.side = "right"
---------------------------------------------------------------------------------
-- vim config
vim.opt.autoindent = true
vim.opt.mouse = 'a'
vim.opt.ttyfast = true
vim.opt.cmdheight = 0
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.smartcase = true
vim.opt.timeoutlen = 10
vim.cmd [[
  augroup highlight_yank
  autocmd!
  au TextYankPost * silent! lua vim.highlight.on_yank({ higroup="Visual", timeout=100 })
  augroup END
]]
---------------------------------------------------------------------------------
-- configure key bindings
lvim.keys.normal_mode[";"] = ":"
lvim.keys.normal_mode["vv"] = "V"
lvim.keys.normal_mode["<Tab>"] = ":bnext<CR>"
lvim.keys.normal_mode["<S-Tab>"] = ":bprev<CR>"
lvim.keys.normal_mode["<Space>ff"] = false
lvim.keys.normal_mode["<Space>ff"] = ":Telescope live_grep<CR>"
lvim.keys.normal_mode["<Space>fc"] = ":Telescope colorscheme<CR>"
lvim.keys.normal_mode["<Space>fb"] = ":Telescope file_browser<CR>"
lvim.keys.normal_mode["<C-p>"] = ":Telescope git_files<cr>"
lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers<cr>"
vim.keymap.set("n", "<C-a>", function()
    require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<C-x>", function()
    require("dial.map").manipulate("decrement", "normal")
end)
-- 0.2.1
---------------------------------------------------------------------------------
-- Autocommands
vim.api.nvim_create_autocmd("BufEnter", { pattern = { "*.json", "*.jsonc" }, command = "setlocal wrap" })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "zsh",
    callback = function()
        require("nvim-treesitter.highlight").attach(0, "bash")
    end,
})
---------------------------------------------------------------------------------
-- Treesitter and formats
lvim.builtin.treesitter.autotag.enable = true
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.ignore_install = {}
lvim.lsp.installer.setup.ensure_installed = { "jsonls" }
lvim.lsp.installer.setup.automatic_installation = true
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
lvim.lsp.installer.setup.automatic_installation = true
lvim.lsp.templates_dir = join_paths(get_runtime_dir(), "after", "ftplugin")
lvim.format_on_save.enabled = true
lvim.format_on_save.pattern = { "*.lua", "*.py" }
formatters.setup {
    { command = "black" },
    {
        command = "prettier",
        args = { "--print-width", "150" },
        filetypes = { "typescript", "typescriptreact", "javascript" },
    },
}
linters.setup {
    { command = "flake8" },
    { command = "shellcheck", args = { "--severity", "warning" } },
    { command = "codespell",  filetypes = { "*" }, },
}
code_actions.setup { { command = "proselint" } }
---------------------------------------------------------------------------------
-- plugins
lvim.plugins = {
    "onsails/lspkind-nvim",
    "monaqa/dial.nvim",
    'norcalli/nvim-colorizer.lua',
    "nvim-treesitter/nvim-treesitter-textobjects",
    "joshdick/onedark.vim",
    "nvim-tree/nvim-web-devicons",
    "stevearc/dressing.nvim",
    "farmergreg/vim-lastplace",
    "ibhagwan/fzf-lua",
    {
        "metakirby5/codi.vim",
        cmd = "Codi",
    },
    {
        "stevearc/dressing.nvim",
        config = function()
            require("dressing").setup({
                input = { enabled = true },
            })
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    },
    {
        "folke/trouble.nvim",
        cmd = "TroubleToggle",
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
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
        "romgrk/nvim-treesitter-context",
        config = function()
            require("treesitter-context").setup {
                enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
                throttle = true, -- Throttles plugin updates (may improve performance)
                max_lines = 1,   -- How many lines the window should span. Values <= 0 mean no limit.
                patterns = {     -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
                    default = { 'class', 'function', 'method' },
                },
            }
        end
    },
    {
        "folke/twilight.nvim",
        opts = {
            dimming = {
                alpha = 0.5, -- amount of dimming
                -- we try to get the foreground from the highlight groups or fallback color
                color = { "Normal", "#ffffff" },
                term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
                inactive = false,    -- when true, other windows will be fully dimmed (unless they contain the same buffer)
            },
            context = 10,            -- amount of lines we will try to show around the current line
            treesitter = true,       -- use treesitter when available for the filetype
            -- treesitter is used to automatically expand the visible text,
            -- but you can further control the types of nodes that should always be fully expanded
            expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
                "function",
                "method",
                "table",
                "if_statement",
            },
            exclude = {},
        }
    },
    {
        "themaxmarchuk/tailwindcss-colors.nvim",
        config = function()
            -- pass config options here (or nothing to use defaults)
            require("tailwindcss-colors").setup()
        end
    },
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "kkharji/sqlite.lua" },
        config = function()
            require("telescope").load_extension("frecency")
        end,
    },
}

nvim_lsp["tailwindcss"].setup({
    on_attach = function(_client, bufnr)
        require("tailwindcss-colors").buf_attach(bufnr)
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

---------------------------------------------------------------------------------
-- telescope config
require("telescope").load_extension("file_browser")
require("telescope").setup({
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
                }
            }
        }
    }
})
vim.opt.termguicolors = true
vim.g.theme_switcher_loaded = true
lvim.builtin.telescope.theme = "dropdown"
lvim.builtin.telescope.defaults = {
    theme = "",
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    color_devicons = true,
    file_ignore_patterns = { "node_modules" },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "truncate" },
    show_line = true,
    winblend = 0,
    layout_config = {
        height = 0.9,
        width = 0.9,
        prompt_position = "top",
        vertical = { mirror = true, },
        horizontal = { prompt_position = "top", },
    },
    pickers = {
        find_files = {
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }
        },
    },
    vimgrep_arguments = {
        "rg",
        "-L",
        "--trim",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
    },
}

lvim.builtin.telescope.on_config_done = function(telescope)
    pcall(telescope.load_extension, "frecency")
    pcall(telescope.load_extension, "neoclip")
end

require('colorizer').setup()

local augend = require("dial.augend")
require("dial.config").augends:register_group {
    -- default augends used when no group name is specified
    default = {
        augend.integer.alias.decimal,  -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.hex,      -- nonnegative hex number  (0x01, 0x1a1f, etc.)
        augend.date.alias["%Y/%m/%d"], -- date (2022/03/01, etc.)
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
}
