vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "css,eruby,html,htmldjango,javascriptreact,less,pug,sass,scss,typescriptreact",
    callback = function()
        vim.lsp.start {
            cmd = { "emmet-language-server", "--stdio" },
            root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
            init_options = {
                showSuggestionsAsSnippets = true,
                showAbbreviationSuggestions = true,
                showExpandedAbbreviation = "inMarkupAndStylesheetFilesOnly",
            },
        }
    end,
})

return {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
}
