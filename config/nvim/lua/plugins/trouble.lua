return {
    {
        cond = not require("config.vscode").isVscode(),
        "folke/trouble.nvim",
        ---@class trouble.Mode: trouble.Config,trouble.Section.spec
        ---@field desc? string
        ---@field sections? string[]

        ---@class trouble.Config
        ---@field mode? string
        ---@field config? fun(opts:trouble.Config)
        ---@field formatters? table<string,trouble.Formatter> custom formatters
        ---@field filters? table<string, trouble.FilterFn> custom filters
        ---@field sorters? table<string, trouble.SorterFn> custom sorters
        opts = {
            focus = true,
            ---@type trouble.Window.opts
            win = {
                type = "split",
                position = "right",
            },
            modes = {
                preview_float = {
                    mode = "diagnostics",
                    preview = {
                        zindex = 200,
                        type = "float",
                        border = "solid",
                        title = "Preview",
                        relative = "editor",
                        position = { 0, -2 },
                        title_pos = "center",
                        size = { width = 0.3, height = 0.3 },
                    },
                },
            },
        },
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Workspace Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics Triage (Trouble)",
            },
            {
                "<leader>xs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>xl",
                "<cmd>Trouble lsp toggle focus=false<cr>",
                desc = "LSP Locations (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
        specs = {
            "folke/snacks.nvim",
            opts = function(_, opts)
                return vim.tbl_deep_extend("force", opts or {}, {
                    picker = {
                        actions = require("trouble.sources.snacks").actions,
                        win = {
                            input = {
                                keys = {
                                    ["<c-t>"] = {
                                        "trouble_open",
                                        mode = { "n", "i" },
                                    },
                                },
                            },
                        },
                    },
                })
            end,
        },
    },
}
