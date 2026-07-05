local ft = { "markdown", "plaintext", "text" }

return {
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
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = ft,
        opts = {
            file_types = ft
        },
    },
}
