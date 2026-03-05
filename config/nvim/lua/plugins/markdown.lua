local ft = { "markdown", "plaintext", "text" }
return {
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
