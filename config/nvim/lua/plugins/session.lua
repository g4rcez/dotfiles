return {
    {
        cond = not require("config.vscode").isVscode(),
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
    },
}
