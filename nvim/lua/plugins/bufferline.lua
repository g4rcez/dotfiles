return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = function(_, opts)
        opts.options.always_show_bufferline = true
        opts.options.numbers = "ordinal"
        opts.options.separator_style = "slant"
        opts.options.show_buffer_close_icons = true
        opts.options.show_buffer_icons = true
        return opts
    end,
}
