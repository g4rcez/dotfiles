local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
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
        cond = not require("config.vscode").isVscode(),
        "chrisgrieser/nvim-scissors",
        opts = { snippetSelection = { picker = "snacks" } },
        keys = {
            {
                "<leader>cs",
                function()
                    require("scissors").addNewSnippet()
                end,
                mode = { "n", "x" },
                desc = "Snippet add",
            },
            {
                "<leader>cS",
                function()
                    require("scissors").editSnippet()
                end,
                desc = "Snippet edit",
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
            restore_quotes = { normal = [[']], jsx = [["]] },
        },
    },
}
