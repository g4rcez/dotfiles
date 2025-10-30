local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",
    { "smjonas/inc-rename.nvim", opts = {} },
    { "dmmulroy/ts-error-translator.nvim" },
    {
        "stevearc/quicker.nvim",
        event = "FileType qf",
        opts = {
            wrap = false,
            number = true,
            buflisted = true,
            signcolumn = "auto",
            winfixheight = true,
            relativenumber = true,
        },
    },
    { "nmac427/guess-indent.nvim", opts = { auto_cmd = true, override_editorconfig = false } },
    { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = { check_ts = true },
    },
    {
        opts = {},
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
    },
    {
        "tronikelis/ts-autotag.nvim",
        opts = { auto_close = { enabled = true }, auto_rename = { enabled = true } },
    },
    {
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = "VeryLazy",
        opts = {},
    },
    {
        "stevearc/aerial.nvim",
        opts = {},
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    },
    {
        "olrtg/nvim-emmet",
        config = function()
            vim.keymap.set({ "n", "v" }, "<leader>ce", function()
                require("nvim-emmet").wrap_with_abbreviation()
            end, { desc = "[e]mmet" })
        end,
    },
    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = true },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "LazyVim", words = { "LazyVim" } },
                { path = "snacks.nvim", words = { "Snacks" } },
                { path = "lazy.nvim", words = { "LazyVim" } },
            },
        },
    },
    {
        opts = {},
        lazy = false,
        "ThePrimeagen/refactoring.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    },
    {
        "rachartier/tiny-code-action.nvim",
        dependencies = { { "nvim-lua/plenary.nvim" }, { "folke/snacks.nvim" } },
        event = "LspAttach",
        opts = {
            backend = "delta",
            picker = "snacks",
            resolve_timeout = 100,
            backend_opts = {
                diffsofancy = { header_lines_to_remove = 4 },
                delta = { header_lines_to_remove = 4, args = { "--line-numbers" } },
                difftastic = {
                    header_lines_to_remove = 1,
                    args = {
                        "--color=always",
                        "--display=inline",
                        "--syntax-highlight=on",
                    },
                },
            },
            signs = {
                quickfix = { "", { link = "DiagnosticWarning" } },
                others = { "", { link = "DiagnosticWarning" } },
                refactor = { "", { link = "DiagnosticInfo" } },
                ["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
                ["refactor.extract"] = { "", { link = "DiagnosticError" } },
                ["source.organizeImports"] = { "", { link = "DiagnosticWarning" } },
                ["source.fixAll"] = { "󰃢", { link = "DiagnosticError" } },
                ["source"] = { "", { link = "DiagnosticError" } },
                ["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
                ["codeAction"] = { "", { link = "DiagnosticWarning" } },
            },
        },
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
        opts = { use_default_keymaps = false, max_join_length = 180 },
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
}
