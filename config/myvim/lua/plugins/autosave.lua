return {
    {
        cond = not require("config.vscode").isVscode(),
        "okuuva/auto-save.nvim",
        version = "*",
        cmd = "ASToggle",
        event = { "InsertLeave", "TextChanged" },
        opts = {},
    },
}
