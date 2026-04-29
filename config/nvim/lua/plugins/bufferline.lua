return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = function()
            return {
                options = {
                    mode = "buffers",
                    diagnostics = "nvim_lsp",
                    indicator = { style = "none" },
                    highlights = require("catppuccin.special.bufferline").get_theme(),
                },
            }
        end,
    },
}
