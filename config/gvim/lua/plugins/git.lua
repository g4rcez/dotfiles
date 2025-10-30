return {
    { "lewis6991/gitsigns.nvim" },
    {
        "sindrets/diffview.nvim",
        opts = {
            default = {
                layout = "diff3_horizontal",
                disable_diagnostics = false,
                winbar_info = false,
            },
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "folke/snacks.nvim",
        },
    },
}
