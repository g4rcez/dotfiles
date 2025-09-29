return {
    {
        "3rd/image.nvim",
        build = false,
        opts = {
            processor = "magick_cli",
        },
    },
    {
        "bullets-vim/bullets.vim",
        config = function()
            vim.g.bullets_delete_last_bullet_if_empty = 2
        end,
    },
    {
        "HakonHarnes/img-clip.nvim",
        opts = {
            default = {
                use_absolute_path = true,
                prompt_for_file_name = false,
                embed_image_as_base64 = false,
                drag_and_drop = { insert_mode = true },
            },
            filetypes = {
                codecompanion = {
                    prompt_for_file_name = false,
                    template = "[Image]($FILE_PATH)",
                    use_absolute_path = true,
                },
            },
        },
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
            heading = {
                sign = true,
                icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
                backgrounds = {
                    "Headline1Bg",
                    "Headline2Bg",
                    "Headline3Bg",
                    "Headline4Bg",
                    "Headline5Bg",
                    "Headline6Bg",
                },
                foregrounds = {
                    "Headline1Fg",
                    "Headline2Fg",
                    "Headline3Fg",
                    "Headline4Fg",
                    "Headline5Fg",
                    "Headline6Fg",
                },
            },
        },
    },
}
