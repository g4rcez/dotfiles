vim.o.background = "dark"
vim.api.nvim_set_var("vim_markdown_frontmatter ", 1)

return {
    {
        "rcarriga/nvim-notify",
        opts = {
            level = 4,
            render = "minimal",
            stages = "static",
        },
    },
}
