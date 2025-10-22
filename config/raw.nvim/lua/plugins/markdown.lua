return {
    {
        "bngarren/checkmate.nvim",
        ft = "markdown",
        opts = {
            files = {
                "*.md",
                "todo",
                "TODO",
                "tasks",
                "*.plan",
                "*.todo",
                "todo.md",
                "TODO.md",
                "*.todo.md",
                "project/**/todo.md",
            },
        },
    },
    {
        "bullets-vim/bullets.vim",
        config = function()
            vim.g.bullets_delete_last_bullet_if_empty = 2
        end,
    },
    {
        lazy = false,
        priority = 49,
        "OXY2DEV/markview.nvim",
        dependencies = { "saghen/blink.cmp" },
        --- Configuration table for `markview.nvim`.
        ---@class mkv.config
        ---
        ---@field experimental config.experimental | fun(): config.experimental
        ---@field highlight_groups { [string]: config.hl } | fun(): { [string]: config.hl }
        ---@field html config.html | fun(): config.html
        ---@field latex config.latex | fun(): config.latex
        ---@field markdown config.markdown | fun(): config.markdown
        ---@field markdown_inline config.markdown_inline | fun(): config.markdown_inline
        ---@field preview config.preview | fun(): config.preview
        ---@field renderers config.renderer[] | fun(): config.renderer[]
        ---@field typst config.typst | fun(): config.typst
        ---@field yaml config.yaml | fun(): config.yaml
        opts = {
            preview = {
                icon_provider = "devicons",
            },
        },
    },
    {
        enabled = false,
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion", "Avante" },
        opts = {
            file_types = { "markdown", "Avante" },
            code = { style = "none" },
            bullet = { enabled = true },
            checkbox = {
                enabled = true,
                position = "inline",
                checked = { icon = "   󰱒 ", highlight = "RenderMarkdownChecked", scope_highlight = nil },
                unchecked = { icon = "   󰄱 ", highlight = "RenderMarkdownUnchecked", scope_highlight = nil },
            },
            html = { enabled = true, comment = { conceal = false } },
            link = {
                image = vim.g.neovim_mode == "skitty" and "" or "󰥶 ",
                custom = { youtu = { pattern = "youtu%.be", icon = "󰗃 " } },
            },
        },
    },
}
