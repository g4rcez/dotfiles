local lsp = {
    "html",
    "bashls",
    "cssls",
    "emmet_ls",
    "jsonls",
    "css_variables",
    "denols",
    "dockerls",
    "docker_compose_language_service",
    "docker_language_server",
    "lua_ls",
    "harper_ls",
    "oxlint",
    "eslint",
    "rust_analyzer",
    "tailwindcss",
    "tsgo",
    "yamlls",
    "kulala_ls",
}

return {
    fmt = { "prettier", "shfmt", "stylua", "eslint_d", "rustywind", "oxfmt" },
    lsp = lsp,
    mason_lsp = vim.tbl_filter(function(server)
        return server ~= "kulala_ls"
    end, lsp),
}
