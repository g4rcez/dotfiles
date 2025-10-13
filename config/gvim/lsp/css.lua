local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config("cssls", { capabilities = capabilities })

return {
    name = "cssls",
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_dir = vim.fs.dirname(vim.fs.find({ "package.json", ".git" }, { upward = true })[1]),
    settings = {
        css = {
            validate = true,
            hover = {
                documentation = true,
                references = true,
            },
        },
        scss = {
            validate = true,
            hover = {
                documentation = true,
                references = true,
            },
        },
    },
}
