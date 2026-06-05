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
        opts = {
            adapters = {
                ["neotest-vitest"] = {},
                ["neotest-bun"] = {},
            },
        },
    },
}
