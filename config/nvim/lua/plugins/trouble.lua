return {
    {
        cmd = { "Trouble" },
        "folke/trouble.nvim",
        opts = {
            auto_close = true, -- auto close when there are no items
            auto_open = false, -- auto open when there are items
            auto_preview = true, -- automatically open preview when on an item
            auto_refresh = true, -- auto refresh when open
            auto_jump = false, -- auto jump to the item when there's only one
            focus = true, -- Focus the window when opened
            restore = true, -- restores the last location in the list when opening
            follow = true, -- Follow the current item
            indent_guides = true, -- show indent guides
            max_items = 200, -- limit number of items that can be displayed per section
            multiline = true, -- render multi-line messages
            pinned = false, -- When pinned, the opened trouble window will be bound to the current buffer
            warn_no_results = true, -- show a warning when there are no results
            open_no_results = false, -- open the trouble window when there are no results
            ---@type trouble.Window.opts
            win = {}, -- window options for the results window. Can be a split or a floating window.
            -- Window options for the preview window. Can be a split, floating window,
            -- or `main` to show the preview in the main editor window.
            ---@type trouble.Window.opts
            preview = { type = "main", scratch = true },
            -- Throttle/Debounce settings. Should usually not be changed.
            ---@type table<string, number|{ms:number, debounce?:boolean}>
            throttle = {
                refresh = 20, -- fetches new data when needed
                update = 10, -- updates the window
                render = 10, -- renders the window
                follow = 100, -- follows the current item
                preview = { ms = 100, debounce = true }, -- shows the preview for the current item
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
                        -- remove Package since luals uses it for control flow structures
                        ["not"] = { ft = "lua", kind = "Package" },
                        any = {
                            -- all symbol kinds for help / markdown files
                            ft = { "help", "markdown" },
                            -- default set of symbol kinds
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
