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
                    custom_filter = function(buf_id, _buf_ids)
                        local tab = tostring(vim.api.nvim_get_current_tabpage())
                        local tags = vim.b[buf_id].workspace_tabs or {}
                        return tags[tab] == true
                    end,
                },
            }
        end,
    },
}
