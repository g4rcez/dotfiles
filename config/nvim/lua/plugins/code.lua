local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",
    { "smjonas/inc-rename.nvim", opts = {} },
    { enabled = false, "windwp/nvim-ts-autotag", config = true },
    {
        "tronikelis/ts-autotag.nvim",
        opts = { auto_close = { enabled = true }, auto_rename = { enabled = true } },
    },
    { "dmmulroy/ts-error-translator.nvim" },
    { "stevearc/quicker.nvim", event = "FileType qf", opts = {} },
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
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = { check_ts = true },
    },
    {
        enabled = false,
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        opts = { preset = "minimal" },
    },
}
