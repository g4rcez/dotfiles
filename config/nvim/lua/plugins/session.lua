return {
    {
        "stevearc/resession.nvim",
        lazy = false,
        opts = {},
        config = function(_, opts)
            local resession = require("resession")
            resession.setup(opts)

            -- Tag each buffer with the tabpage(s) it was entered in.
            -- bufferline reads vim.b[buf].workspace_tabs to filter per-tab.
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function(ev)
                    local tab = tostring(vim.api.nvim_get_current_tabpage())
                    local tags = vim.b[ev.buf].workspace_tabs or {}
                    tags[tab] = true
                    vim.b[ev.buf].workspace_tabs = tags
                end,
            })

            -- Auto-save all workspaces on exit
            vim.api.nvim_create_autocmd("VimLeavePre", {
                callback = function()
                    resession.save("last", { notify = false })
                end,
            })
        end,
    },
}
