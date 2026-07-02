return {
    {
        cond = not require("config.vscode").isVscode(),
        "folke/persistence.nvim",
        event = "BufReadPre",
        keys = {
            {
                "<leader>ww",
                function()
                    require("persistence").load()
                end,
                desc = "Restore workspace session",
            },
            {
                "<leader>wl",
                function()
                    require("persistence").load { last = true }
                end,
                desc = "Restore last session",
            },
            {
                "<leader>ws",
                function()
                    require("persistence").select()
                end,
                desc = "Select workspace session",
            },
            {
                "<leader>wS",
                function()
                    require("persistence").save()
                end,
                desc = "Save workspace session",
            },
            {
                "<leader>wd",
                function()
                    require("persistence").stop()
                end,
                desc = "Stop workspace session",
            },
        },
        opts = {},
    },
}
