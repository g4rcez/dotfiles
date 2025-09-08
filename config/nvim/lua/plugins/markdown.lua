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
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion", "Avante" },
        opts = {
            file_types = { "markdown", "Avante" },
            bullet = {
                enabled = true,
            },
            checkbox = {
                enabled = true,
                -- Determines how icons fill the available space:
                --  inline:  underlying text is concealed resulting in a left aligned icon
                --  overlay: result is left padded with spaces to hide any additional text
                position = "inline",
                unchecked = {
                    -- Replaces '[ ]' of 'task_list_marker_unchecked'
                    icon = "   󰄱 ",
                    -- Highlight for the unchecked icon
                    highlight = "RenderMarkdownUnchecked",
                    -- Highlight for item associated with unchecked checkbox
                    scope_highlight = nil,
                },
                checked = {
                    -- Replaces '[x]' of 'task_list_marker_checked'
                    icon = "   󰱒 ",
                    -- Highlight for the checked icon
                    highlight = "RenderMarkdownChecked",
                    -- Highlight for item associated with checked checkbox
                    scope_highlight = nil,
                },
            },
            html = {
                -- Turn on / off all HTML rendering
                enabled = true,
                comment = {
                    -- Turn on / off HTML comment concealing
                    conceal = false,
                },
            },
            -- Add custom icons lamw26wmal
            link = {
                image = vim.g.neovim_mode == "skitty" and "" or "󰥶 ",
                custom = {
                    youtu = { pattern = "youtu%.be", icon = "󰗃 " },
                },
            },
            heading = {
                sign = false,
                icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
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
            code = {
                -- if I'm not using yabai, I cannot make the color of the codeblocks
                -- transparent, so just disabling all rendering 😢
                style = "none",
            },
        },
    },
    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
            default = {
                use_absolute_path = true,
                prompt_for_file_name = false,
                embed_image_as_base64 = false,
                drag_and_drop = { insert_mode = true },
            },
        },
    },
}
