return {
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            { cond = not require("config.vscode").isVscode(), "saghen/blink.cmp" },
        },
    },
}
