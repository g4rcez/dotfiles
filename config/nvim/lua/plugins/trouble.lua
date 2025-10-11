return {
    {
        cmd = { "Trouble" },
        "folke/trouble.nvim",
        opts = {
            auto_close = true,
            auto_open = false,
            auto_preview = true,
            auto_refresh = true,
            auto_jump = false,
            focus = true,
            restore = true,
            follow = true,
            indent_guides = true,
            max_items = 300,
            multiline = true,
            pinned = false,
            warn_no_results = true,
            open_no_results = false,
            ---@type trouble.Window.opts
            win = {},
            ---@type trouble.Window.opts
            preview = { type = "main", scratch = true },
            ---@type table<string, number|{ms:number, debounce?:boolean}>
            throttle = {
                refresh = 20,
                update = 10,
                render = 10,
                follow = 100,
                preview = { ms = 100, debounce = true },
            },
            -- Key mappings can be set to the name of a builtin action,
            -- or you can define your own custom action.
            ---@type table<string, trouble.Action.spec|false>
            ---@type table<string, trouble.Mode>
            modes = {
                lsp = { win = { position = "right" } },
                lsp_references = { params = { include_declaration = true } },
                lsp_base = {
                    params = {
                        include_current = false,
                    },
                },
                symbols = {
                    desc = "document symbols",
                    mode = "lsp_document_symbols",
                    focus = false,
                    win = { position = "right" },
                    filter = {
                        ["not"] = { ft = "lua", kind = "Package" },
                        any = {
                            ft = { "help", "markdown" },
                            kind = {
                                "Class",
                                "Constructor",
                                "Enum",
                                "Field",
                                "Function",
                                "Interface",
                                "Method",
                                "Module",
                                "Namespace",
                                "Package",
                                "Property",
                                "Struct",
                                "Trait",
                            },
                        },
                    },
                },
            },
            icons = {
                ---@type trouble.Indent.symbols
                indent = {
                    top = "│ ",
                    middle = "├╴",
                    last = "╰╴",
                    fold_open = " ",
                    fold_closed = " ",
                    ws = "  ",
                },
                folder_closed = " ",
                folder_open = " ",
                kinds = {
                    Array = " ",
                    Boolean = "󰨙 ",
                    Class = " ",
                    Constant = "󰏿 ",
                    Constructor = " ",
                    Enum = " ",
                    EnumMember = " ",
                    Event = " ",
                    Field = " ",
                    File = " ",
                    Function = "󰊕 ",
                    Interface = " ",
                    Key = " ",
                    Method = "󰊕 ",
                    Module = " ",
                    Namespace = "󰦮 ",
                    Null = " ",
                    Number = "󰎠 ",
                    Object = " ",
                    Operator = " ",
                    Package = " ",
                    Property = " ",
                    String = " ",
                    Struct = "󰆼 ",
                    TypeParameter = " ",
                    Variable = "󰀫 ",
                },
            },
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
