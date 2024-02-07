local M = {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "nvim-lua/plenary.nvim",
    },
}

M.servers = {
    "bashls",
    "cssls",
    "html",
    "jsonls",
    "lua_ls",
    "marksman",
    "tailwindcss",
    "tsserver",
    "yamlls",
}

function M.config()
    require("mason").setup({ ui = { border = "rounded", ensure_installed = { "prettier" } } })
    require("mason-lspconfig").setup({ ensure_installed = M.servers })
end

return M
