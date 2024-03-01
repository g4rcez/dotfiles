return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = function(_, opts)
        local options = {
            numbers = "ordinal",
            separator_style = "slant",
            always_show_bufferline = true,
        }
        opts.options = {
            opts.options,
            options,
        }
        return opts
    end,
}
