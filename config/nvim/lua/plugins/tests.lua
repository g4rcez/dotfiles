return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "arthur944/neotest-bun",
            "nvim-lua/plenary.nvim",
            "nvim-neotest/nvim-nio",
            "marilari88/neotest-vitest",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            {
                "<leader>Tn",
                function()
                    require("neotest").run.run()
                end,
                desc = "Test nearest",
            },
            {
                "<leader>Tf",
                function()
                    require("neotest").run.run(vim.fn.expand "%")
                end,
                desc = "Test file",
            },
            {
                "<leader>Tl",
                function()
                    require("neotest").run.run_last()
                end,
                desc = "Test last",
            },
            {
                "<leader>Ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Test summary",
            },
            {
                "<leader>To",
                function()
                    require("neotest").output.open { enter = true, auto_close = true }
                end,
                desc = "Test output",
            },
            {
                "<leader>TO",
                function()
                    require("neotest").output_panel.toggle()
                end,
                desc = "Test output panel",
            },
            {
                "<leader>Ta",
                function()
                    require("neotest").run.attach()
                end,
                desc = "Test attach",
            },
            {
                "<leader>Tw",
                function()
                    require("neotest").watch.toggle(vim.fn.expand "%")
                end,
                desc = "Test watch file",
            },
            {
                "<leader>TS",
                function()
                    require("neotest").run.stop()
                end,
                desc = "Test stop",
            },
        },
        opts = {
            adapters = {
                ["neotest-vitest"] = {},
                ["neotest-bun"] = {},
            },
            output_panel = {
                open = "botright split | resize 12",
            },
        },
    },
}
