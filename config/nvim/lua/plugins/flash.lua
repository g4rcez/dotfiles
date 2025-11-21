return {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
        label = { style = "overlay", rainbow = { enabled = true, shade = 5 } },
        modes = {
            char = { jump_labels = true },
            treesitter = {
                labels = "abcdefghijklmnopqrstuvwxyz",
                jump = { pos = "range", autojump = true },
                search = { incremental = true },
                label = { before = true, after = true, style = "inline" },
                highlight = { backdrop = true, matches = true },
            },
            treesitter_search = {
                jump = { pos = "range" },
                search = { multi_window = true, wrap = true, incremental = false },
                label = { before = true, after = true, style = "inline" },
            },
        },
    },
    keys = {
        {
            "<leader>Ff",
            mode = { "n" },
            function()
                require("flash").jump({})
            end,
            desc = "Flash jump",
        },
        {
            "<C-f>",
            mode = { "n" },
            function()
                require("flash").jump({})
            end,
            desc = "Flash jump",
        },
    },
}
