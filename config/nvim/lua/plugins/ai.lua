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
            "ravitemer/codecompanion-history.nvim",
        },
        opts = {
            strategies = {
                chat = {
                    adapter = "anthropic",
                    model = "claude-sonnet-4-20250514",
                },
                inline = {
                    adapter = "anthropic",
                    model = "claude-sonnet-4-20250514",
                },
            },
            extensions = {
                history = {
                    enabled = true,
                    opts = {
                        keymap = "gh",
                        save_chat_keymap = "sc",
                        auto_save = true,
                        expiration_days = 0,
                        picker = "snacks",
                        auto_generate_title = true,
                        continue_last_chat = false,
                        delete_on_clearing_chat = false,
                        dir_to_save = vim.fn.stdpath "data" .. "/codecompanion-history",
                        enable_logging = false,
                    },
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
