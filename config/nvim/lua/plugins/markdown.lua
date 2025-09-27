return {
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
    },
    {
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
