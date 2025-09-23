local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",
    { "smjonas/inc-rename.nvim", opts = {} },
    { "dmmulroy/ts-error-translator.nvim" },
    { opts = {}, "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },
    { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = "VeryLazy",
        opts = {},
    },
    { "nmac427/guess-indent.nvim", opts = { auto_cmd = true, override_editorconfig = false } },
    {
        "stevearc/aerial.nvim",
        opts = {},
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    },
    {
        "olrtg/nvim-emmet",
        config = function()
            vim.keymap.set(
                { "n", "v" },
                "<leader>ce",
                require("nvim-emmet").wrap_with_abbreviation,
                { desc = "[e]mmet" }
            )
        end,
    },
    {
        "stevearc/quicker.nvim",
        event = "FileType qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {},
    },
    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = true },
    },
    {
        "axelvc/template-string.nvim",
        ft = fileTypes,
        event = "InsertEnter",
        opts = {
            filetypes = fileTypes,
            remove_template_string = true,
            restore_quotes = {
                normal = [[']],
                jsx = [["]],
            },
        },
    },
    {
        "andymass/vim-matchup",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = function(_, opts)
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
            require("nvim-treesitter.configs").setup { matchup = { enable = true } }
            return opts
        end,
    },
    {
        "Wansmer/treesj",
        opts = { use_default_keymaps = false, max_join_length = 1000 },
        keys = {
            { "<leader>cJ", "<cmd>TSJToggle<cr>", desc = "[J]oin Toggle" },
            { "<leader>cj", "<cmd>TSJToggle<cr>", desc = "[j]oin Toggle" },
        },
    },
    {
        "brenoprata10/nvim-highlight-colors",
        opts = {
            enable_hex = true,
            enable_hsl = true,
            enable_rgb = true,
            exclude_buftypes = {},
            render = "background",
            enable_tailwind = true,
            exclude_filetypes = {},
            virtual_symbol = "■",
            enable_short_hex = true,
            enable_var_usage = true,
            enable_named_colors = true,
            virtual_symbol_prefix = "",
            virtual_symbol_suffix = " ",
            virtual_symbol_position = "inline",
        },
    },
    {
        "windwp/nvim-ts-autotag",
        config = true,
        opts = {
            opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = true,
            },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = { check_ts = true },
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        opts = {
            preset = "minimal",
            transparent_bg = false, -- Set the background of the diagnostic to transparent
            transparent_cursorline = false, -- Set the background of the cursorline to transparent (only one the first diagnostic)
            hi = {
                error = "DiagnosticError", -- Highlight group for error messages
                warn = "DiagnosticWarn", -- Highlight group for warning messages
                info = "DiagnosticInfo", -- Highlight group for informational messages
                hint = "DiagnosticHint", -- Highlight group for hint or suggestion messages
                arrow = "NonText", -- Highlight group for diagnostic arrows
                background = "CursorLine",
                mixing_color = "None",
            },
            options = {
                -- Display the source of the diagnostic (e.g., basedpyright, vsserver, lua_ls etc.)
                show_source = { enabled = true, if_many = true },
                use_icons_from_diagnostic = false,
                set_arrow_to_diag_color = true,
                add_messages = true,
                throttle = 200,
                softwrap = 30,
                multilines = { enabled = true, always_show = false, trim_whitespaces = false, tabstop = 4 },
                show_all_diags_on_cursorline = false,
                -- Enable diagnostics in Insert mode
                -- If enabled, it is better to set the `throttle` option to 0 to avoid visual artifacts
                enable_on_insert = false,
                -- Enable diagnostics in Select mode (e.g when auto inserting with Blink)
                enable_on_select = false,
                overflow = { mode = "wrap", padding = 0 },
                -- Configuration for breaking long messages into separate lines
                break_line = { enabled = true, after = 30 },
                format = nil,
                virt_texts = { priority = 2048 },
                severity = {
                    vim.diagnostic.severity.ERROR,
                    vim.diagnostic.severity.WARN,
                    vim.diagnostic.severity.INFO,
                    vim.diagnostic.severity.HINT,
                },
                overwrite_events = nil,
            },
            disabled_ft = {},
        },
    },
}
