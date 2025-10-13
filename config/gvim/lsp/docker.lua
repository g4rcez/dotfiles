vim.lsp.config("dockerls", {
    settings = {
        docker = {
            languageserver = { formatter = { ignoreMultilineInstructions = true } },
        },
    },
})

return {
    cmd = { "docker-langserver", "--stdio" },
    filetypes = { "Dockerfile", "dockerfile" }
}
