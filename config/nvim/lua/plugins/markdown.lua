local ft = { "markdown", "plaintext", "text" }
return {
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        dependencies = { "saghen/blink.cmp" },
    },
    {
        "yousefhadder/markdown-plus.nvim",
        ft = ft,
        opts = {
            filetypes = ft,
            code_block = {
                enabled = true,
                fence_style = "backtick",
                languages = { "lua", "python", "javascript", "typescript", "bash", "json", "yaml", "markdown", "csharp", "http" },
            },
        },
    },
}
