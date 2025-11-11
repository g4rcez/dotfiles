return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = function(_, opts)
            local colors = {
                white = "#ffffff",
                bg = "#1E1E2E",
                fg = "#cdd6f4",
                yellow = "#f9e2af",
                cyan = "#89dceb",
                darkblue = "#081633",
                green = "#a6e3a1",
                orange = "#fab387",
                violet = "#b4befe",
                magenta = "#cba6f7",
                blue = "#89b4fa",
                red = "#f38ba8",
            }
            local conditions = {
                buffer_not_empty = function()
                    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
                end,
                hide_in_width = function()
                    return vim.fn.winwidth(0) > 80
                end,
                check_git_workspace = function()
                    local filepath = vim.fn.expand("%:p:h")
                    local gitdir = vim.fn.finddir(".git", filepath .. ";")
                    return gitdir and #gitdir > 0 and #gitdir < #filepath
                end,
            }
            local config = {
                theme = "catppuccin",
                options = {
                    component_separators = "",
                    section_separators = "",
                    theme = {
                        normal = { c = { fg = colors.fg, bg = colors.bg } },
                        inactive = { c = { fg = colors.fg, bg = colors.bg } },
                    },
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    -- These will be filled later
                    lualine_c = {},
                    lualine_x = {},
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    lualine_c = {},
                    lualine_x = {},
                },
            }

            local function onLeft(component)
                table.insert(config.sections.lualine_c, component)
            end

            local function onRight(component)
                table.insert(config.sections.lualine_x, component)
            end

            onLeft({
                function()
                    return " "
                end,
                color = { fg = colors.blue },
                padding = { left = 0, right = 1 },
            })

            onLeft({
                function()
                    return ""
                end,
                color = function()
                    local mode_color = {
                        n = colors.white,
                        i = colors.green,
                        v = colors.green,
                        [""] = colors.blue,
                        V = colors.blue,
                        c = colors.magenta,
                        no = colors.red,
                        s = colors.orange,
                        S = colors.orange,
                        [""] = colors.orange,
                        ic = colors.yellow,
                        R = colors.violet,
                        Rv = colors.violet,
                        cv = colors.red,
                        ce = colors.red,
                        r = colors.cyan,
                        rm = colors.cyan,
                        ["r?"] = colors.cyan,
                        ["!"] = colors.red,
                        t = colors.red,
                    }
                    return { fg = mode_color[vim.fn.mode()] }
                end,
                padding = { right = 1 },
            })

            onLeft({
                "filesize",
                cond = conditions.buffer_not_empty,
            })

            onLeft({
                "filename",
                cond = conditions.buffer_not_empty,
                color = { fg = colors.magenta, gui = "bold" },
            })

            onLeft({
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = { error = " ", warn = " ", info = " " },
                diagnostics_color = {
                    error = { fg = colors.red },
                    warn = { fg = colors.yellow },
                    info = { fg = colors.cyan },
                },
            })
            onLeft({
                function()
                    return "%="
                end,
            })
            onRight({
                function()
                    local msg = "No Active Lsp"
                    local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
                    local clients = vim.lsp.get_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end,
                icon = " ",
                color = { fg = colors.fg, gui = "bold" },
            })

            onRight({
                "o:encoding",
                fmt = string.upper,
                cond = conditions.hide_in_width,
                color = { fg = colors.green, gui = "bold" },
            })

            onRight({
                "branch",
                icon = "",
                color = { fg = colors.violet, gui = "bold" },
            })

            onRight({
                "diff",
                symbols = { added = " ", modified = "󰝤 ", removed = " " },
                diff_color = {
                    added = { fg = colors.green },
                    modified = { fg = colors.orange },
                    removed = { fg = colors.red },
                },
                cond = conditions.hide_in_width,
            })

            onRight({ "location" })
            onRight({ "progress", color = { fg = colors.fg, gui = "bold" } })

            onRight({
                function()
                    return " "
                end,
                color = { fg = colors.blue },
                padding = { left = 1 },
            })
            return vim.tbl_deep_extend("force", opts, config)
        end,
    },
}
