return {
    {
        cmd = { "Trouble" },
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
            win = { type = "float" },
        },
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
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
