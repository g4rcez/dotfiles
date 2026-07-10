local ft = { "markdown", "vimwiki" }

return {
    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
            default = {
                dir_path = function()
                    return require("config.markdown_viewer").image_dir()
                end,
                use_absolute_path = false,
                prompt_for_file_name = false,
                embed_image_as_base64 = false,
                drag_and_drop = { insert_mode = true },
                file_name = "%Y-%m-%d-%H-%M-%S",
                template = "![$CURSOR]($FILE_PATH)",
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = ft,
        opts = {
            completions = { lsp = { enabled = true } },
            preset = "obsidian",
            file_types = ft,
            heading = {
                foregrounds = {
                    "RenderMarkdownH1",
                    "RenderMarkdownH2",
                    "RenderMarkdownH3",
                    "RenderMarkdownH4",
                    "RenderMarkdownH5",
                    "RenderMarkdownH6",
                },
                backgrounds = {
                    "RenderMarkdownH1Bg",
                    "RenderMarkdownH2Bg",
                    "RenderMarkdownH3Bg",
                    "RenderMarkdownH4Bg",
                    "RenderMarkdownH5Bg",
                    "RenderMarkdownH6Bg",
                },
            },
        },
    },
}
