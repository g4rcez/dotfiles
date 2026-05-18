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
                    separator_style = "slant",
                    indicator = { style = "icon", icon = "▎" },
                    diagnostics_indicator = function(count, level)
                        local icons = { error = " ", warning = " " }
                        return (icons[level] or "") .. count
                    end,
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                    color_icons = true,
                    modified_icon = "●",
                    left_trunc_marker = "",
                    right_trunc_marker = "",
                    highlights = require("catppuccin.special.bufferline").get_theme(),
                },
            }
        end,
    },
}
