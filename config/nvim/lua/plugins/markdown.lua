local ft = { "markdown", "vimwiki", "Avante" }

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
        "yousefhadder/markdown-plus.nvim",
        ft = ft,
        opts = {
            filetypes = ft,
            keymaps = { enabled = true },
            table = { keymaps = { enabled = true } },
            list = {
                smart_outdent = true,
                whitespace = "single",
                whitespace_width = 4,
                checkbox_completion = {
                    enabled = true,
                    format = "dataview",
                    update_existing = true,
                    date_format = "%Y-%m-%d",
                    remove_on_uncheck = true,
                },
            },
        },
    },
}
