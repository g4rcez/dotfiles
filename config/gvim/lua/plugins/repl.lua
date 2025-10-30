return {
    {
        "Zeioth/compiler.nvim",
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
        dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
        opts = {},
    },
    {
        "stevearc/overseer.nvim",
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
        opts = {
            task_list = {
                direction = "bottom",
                min_height = 25,
                max_height = 25,
                default_detail = 1,
            },
        },
    },
    {
        "marilari88/twoslash-queries.nvim",
        config = function()
            require("twoslash-queries").setup {
                multi_line = true,
                is_enabled = true,
                highlight = "Type",
            }
        end,
    },
    {
        "josephburgess/nvumi",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            virtual_text = "newline",
            prefix = " 🚀 ",
            date_format = "iso",
            keys = { run = "<CR>", reset = "R", yank = "<leader>y", yank_all = "<leader>Y" },
            custom_conversions = {},
            custom_functions = {},
        },
    },
}
