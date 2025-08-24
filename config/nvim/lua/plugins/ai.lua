return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
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
        enabled = false,
        "yetone/avante.nvim",
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            model = "claude-sonnet-4-20250514",
            chat = {
                model = "claude-sonnet-4-20250514",
            },
            inline = {
                model = "claude-sonnet-4-20250514",
            },
        },
    },
}
