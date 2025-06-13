return {
    "augmentcode/augment.vim",
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            strategies = {
                chat = {
                    adapter = "anthropic",
                    model = "claude-sonnet-4-20250514"
                },
                inline = {
                    adapter = "anthropic",
                    model = "claude-sonnet-4-20250514"
                },
            },
        },
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
        "yetone/avante.nvim",
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
