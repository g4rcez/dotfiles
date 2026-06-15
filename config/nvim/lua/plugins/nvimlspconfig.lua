return {
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
            { cond = not require("config.vscode").isVscode(), "saghen/blink.cmp" },
        },
    },
}
