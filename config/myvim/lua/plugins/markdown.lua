return {
    {
        "yousefhadder/markdown-plus.nvim",
        ft = "markdown",
        opts = {
            enabled = true,
            toc = { initial_depth = 2 },
            keymaps = { enabled = true },
            filetypes = { "markdown", "gitcommit" },
            callouts = { default_type = "NOTE", custom_types = {} },
            footnotes = { section_header = "Footnotes", confirm_delete = true },
            features = {
                links = true,
                table = true,
                images = true,
                quotes = true,
                callouts = true,
                footnotes = true,
                code_block = true,
                headers_toc = true,
                list_management = true,
                text_formatting = true,
            },
            table = {
                auto_format = true,
                default_alignment = "left",
                confirm_destructive = true,
                keymaps = { enabled = true, prefix = "<leader>t", insert_mode_navigation = true },
            },
        },
    },
}
