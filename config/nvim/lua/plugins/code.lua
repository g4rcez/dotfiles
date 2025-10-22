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
            inlay_hints = { enabled = false },
            servers = {
                ["cspell-lsp"] = {},
                vstls = {
                    settings = {
                        typescript = {
                            tsserver = { maxTsServerMemory = 12000 },
                            suggest = {
                                enabled = true,
                                completeFunctionCalls = true,
                            },
                            inlayHints = {
                                parameterNames = { enabled = "literals" },
                                parameterTypes = { enabled = true },
                                variableTypes = { enabled = true },
                                propertyDeclarationTypes = { enabled = true },
                                functionLikeReturnTypes = { enabled = true },
                                enumMemberValues = { enabled = true },
                            }
                        },
                    }
                }
            },
        },
    },
}
