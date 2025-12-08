return {
    {
        cond = not require("config.vscode").isVscode(),
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        opts = {
            preset = "minimal",
            transparent_bg = false,
            transparent_cursorline = true,
            options = {
                multilines = { enabled = true },
            },
        },
    },
}
