return {
    { --nice markdown inline rendering
        "MeanderingProgrammer/render-markdown.nvim",
        event = "VeryLazy",
        priority = 1000,
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        keys = {
            { "<leader>mr", ":RenderMarkdown toggle<CR>", desc = "Markdown Render Toggle" },
        },
        opts = {
            file_types = { "markdown", "plaintext", "text" },
            bullet = { right_pad = 2 },
            heading = {
                left_pad = 2,
                sign = false,
                right_pad = 4,
                width = "block",
                position = "inline",
                icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
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
