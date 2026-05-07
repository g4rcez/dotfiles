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
    {
        "MeanderingProgrammer/render-markdown.nvim",
        event = "VeryLazy",
        priority = 1000,
        ft = ft,
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>mr", ":RenderMarkdown toggle<CR>", desc = "Markdown Render Toggle" },
        },
        opts = {
            file_types = ft,
            bullet = { right_pad = 2 },
            heading = {
                left_pad = 2,
                sign = false,
                right_pad = 4,
                width = "block",
                position = "inline",
            },
            code = {
                sign = false,
                left_pad = 2,
                right_pad = 4,
                border = "thick",
            },
        },
    },
}
