return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                globalstatus = true,
                icons_enabled = true,
                theme = "catppuccin",
                component_separators = " ",
                section_separators = " ",
                disabled_filetypes = { statusline = {}, winbar = {} },
            },
            extensions = { "quickfix", "oil", "lazy" },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {},
                lualine_c = {
                    {
                        function()
                            local gitsigns = vim.b.gitsigns_status_dict
                            if not gitsigns then
                                return ""
                            end
                            local parts = {}
                            if gitsigns.added and gitsigns.added > 0 then
                                table.insert(parts, "%#DiffAdd# " .. gitsigns.added)
                            end
                            if gitsigns.changed and gitsigns.changed > 0 then
                                table.insert(parts, "%#DiffChange# " .. gitsigns.changed)
                            end
                            if gitsigns.removed and gitsigns.removed > 0 then
                                table.insert(parts, "%#DiffDelete# " .. gitsigns.removed)
                            end
                            if #parts > 0 then
                                return table.concat(parts, " ") .. "%*"
                            end
                            return ""
                        end,
                    },
                    { "filename", path = 0, icons_enabled = true, file_status = true },
                    {
                        "diagnostics",
                        sources = { "nvim_lsp", "nvim_diagnostic", "coc" },
                        sections = { "error", "warn", "info", "hint" },
                        diagnostics_color = { error = "DiagnosticError", warn = "DiagnosticWarn", info = "DiagnosticInfo", hint = "DiagnosticHint" },
                        symbols = { error = " ", warn = " ", info = " ", hint = "󰋖" },
                        colored = true,
                        update_in_insert = false,
                        always_visible = false,
                    },
                },
                lualine_x = {
                    "branch",
                    function()
                        if vim.v.hlsearch == 0 then
                            return ""
                        end
                        local last_search = vim.fn.getreg "/"
                        if not last_search or last_search == "" then
                            return ""
                        end
                        local searchcount = vim.fn.searchcount { maxcount = 9999 }
                        return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
                    end,
                    "lsp_status",
                    "location",
                },
                lualine_y = {},
                lualine_z = {},
            }
        },
    },
}
