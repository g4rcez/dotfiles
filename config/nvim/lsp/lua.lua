vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                ignoreSubmodules = true,
                library = { vim.env.VIMRUNTIME, vim.api.nvim_get_runtime_file("", true) },
            },
        },
    },
})
