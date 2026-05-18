local mode_icons = {
    NORMAL = "󰋜 ",
    INSERT = " ",
    VISUAL = "󰈈 ",
    ["V-LINE"] = "󰈈 ",
    ["V-BLOCK"] = "󰈈 ",
    REPLACE = " ",
    ["V-REPLACE"] = " ",
    COMMAND = " ",
    TERMINAL = " ",
    SELECT = "󰒅 ",
    ["S-LINE"] = "󰒅 ",
    ["S-BLOCK"] = "󰒅 ",
    SHELL = " ",
}

return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                globalstatus = true,
                icons_enabled = true,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = { statusline = { "alpha", "dashboard", "snacks_dashboard" }, winbar = {} },
            },
            extensions = { "quickfix", "oil", "lazy", "trouble" },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        fmt = function(m)
                            return (mode_icons[m] or "  ") .. m
                        end,
                    },
                },
                lualine_b = {},
                lualine_c = {
                    { "branch", icon = "" },
                    {
                        "diff",
                        symbols = { added = "+", modified = "~", removed = "-" },
                        source = function()
                            local gs = vim.b.gitsigns_status_dict
                            if gs then
                                return { added = gs.added, modified = gs.changed, removed = gs.removed }
                            end
                        end,
                    },
                    {
                        "filename",
                        path = 1,
                        symbols = { modified = " ●", readonly = "  ", unnamed = " 󰈚", newfile = " 󰎔" },
                    },
                    {
                        function()
                            if vim.v.hlsearch == 0 then
                                return ""
                            end
                            local pat = vim.fn.getreg "/"
                            if not pat or pat == "" then
                                return ""
                            end
                            local ok, sc = pcall(vim.fn.searchcount, { maxcount = 9999 })
                            if not ok or sc.total == 0 then
                                return ""
                            end
                            return " " .. pat .. " [" .. sc.current .. "/" .. sc.total .. "]"
                        end,
                        color = function()
                            local hl = vim.api.nvim_get_hl(0, { name = "Special", link = false })
                            return { fg = hl.fg and ("#%06x"):format(hl.fg) }
                        end,
                    },
                },
                lualine_x = {
                    {
                        "diagnostics",
                        sources = { "nvim_lsp", "nvim_diagnostic" },
                        sections = { "error", "warn", "info", "hint" },
                        diagnostics_color = {
                            error = "DiagnosticError",
                            warn = "DiagnosticWarn",
                            info = "DiagnosticInfo",
                            hint = "DiagnosticHint",
                        },
                        symbols = { error = " ", warn = " ", info = " ", hint = "󰋖 " },
                        colored = true,
                        update_in_insert = false,
                        always_visible = false,
                    },
                    {
                        function()
                            local clients = vim.lsp.get_clients { bufnr = 0 }
                            if #clients == 0 then
                                return ""
                            end
                            local names = {}
                            for _, c in ipairs(clients) do
                                if c.name ~= "copilot" then
                                    table.insert(names, c.name)
                                end
                            end
                            if #names == 0 then
                                return ""
                            end
                            return "󰒋 " .. table.concat(names, ", ")
                        end,
                    },
                    { "filetype" },
                    { "progress" },
                    { "location" },
                },
                lualine_z = {},
                lualine_y = {},
            },
        },
    },
}
