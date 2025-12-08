return {
    { "nvim-neotest/neotest-plenary" },
    {
        "nvim-neotest/neotest",
        opts = { adapters = { "neotest-plenary" } },
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter"
        }
    },
}
