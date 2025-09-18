vim.lsp.config["vtsls"] = {
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    },
    root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
    settings = {
        refactor_auto_rename = true,
        typescript = {
            tsserver = { maxTsServerMemory = 8192 },
            inlayHints = {
                variableTypes = { enabled = true },
                parameterTypes = { enabled = true },
                enumMemberValues = { enabled = true },
                parameterNames = { enabled = "literals" },
                functionLikeReturnTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
            },
        },
    },
}
