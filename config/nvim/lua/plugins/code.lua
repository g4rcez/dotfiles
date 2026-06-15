local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "editorconfig/editorconfig-vim",
    { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
    {
        "Sang-it/fluoride",
        opts = {},
        keys = { { "<leader>cO", "<cmd>Fluoride<cr>", desc = "Fluoride" } },
    },
    {
        cond = not require("config.vscode").isVscode(),
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                "nvim-dap-ui",
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "tronikelis/ts-autotag.nvim",
        ft = fileTypes,
        opts = {
            disable_in_macro = true,
            auto_close = { enabled = true },
            auto_rename = { enabled = true },
        },
    },
    {
        "folke/todo-comments.nvim",
        keys = {
            {
                "<leader>st",
                function()
                    require("snacks").picker.todo_comments()
                end,
                desc = "Todo",
            },
            {
                "<leader>sT",
                function()
                    require("snacks").picker.todo_comments { keywords = { "TODO", "FIX", "FIXME" } }
                end,
                desc = "Todo/Fix/Fixme",
            },
        },
    },
    {
        cond = not require("config.vscode").isVscode(),
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        event = "VeryLazy",
        opts = {},
    },
    {
        cond = not require("config.vscode").isVscode(),
        opts = {},
        event = { "BufReadPost", "BufNewFile" },
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
    },
    {
        cond = not require("config.vscode").isVscode(),
        "olrtg/nvim-emmet",
        keys = {
            {
                "<leader>ce",
                function()
                    require("nvim-emmet").wrap_with_abbreviation()
                end,
                mode = { "n", "v" },
                desc = "[e]mmet",
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
        "brenoprata10/nvim-highlight-colors",
        event = { "BufReadPost", "BufNewFile" },
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
