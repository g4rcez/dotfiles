vim.lsp.config("vtsls", {
    settings = {
        refactor_auto_rename = true,
        typescript = {
            tsserver = { maxTsServerMemory = 8192 },
            inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            },
        },
    },
})
