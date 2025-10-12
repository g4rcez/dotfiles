return {
    {
        opts = {},
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
    },
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                harper_ls = {},
                ["cspell-lsp"] = {}
            },
        },
    },
}
