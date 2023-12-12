return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            tailwindcss = {
                -- exclude a filetype from the default_config
                filetypes_exclude = { "markdown" },
                -- add additional filetypes to the default_config
                filetypes_include = {},
                -- to fully override the default_config, change the below
                -- filetypes = {}
            },
            tsserver = {
                keys = {
                    {
                        "<leader>co",
                        function()
                            vim.lsp.buf.code_action({
                                apply = true,
                                context = {
                                    only = { "source.organizeImports.ts" },
                                    diagnostics = {},
                                },
                            })
                        end,
                        desc = "Organize Imports",
                    },
                    {
                        "<leader>cR",
                        function()
                            vim.lsp.buf.code_action({
                                apply = true,
                                context = {
                                    only = { "source.removeUnused.ts" },
                                    diagnostics = {},
                                },
                            })
                        end,
                        desc = "Remove Unused Imports",
                    },
                },
                settings = {
                    typescript = {
                        format = {
                            indentSize = vim.o.shiftwidth,
                            convertTabsToSpaces = vim.o.expandtab,
                            tabSize = vim.o.tabstop,
                        },
                    },
                    javascript = {
                        format = {
                            indentSize = vim.o.shiftwidth,
                            convertTabsToSpaces = vim.o.expandtab,
                            tabSize = vim.o.tabstop,
                        },
                    },
                    completions = {
                        completeFunctionCalls = true,
                    },
                },
            },
        },
        setup = {
            tailwindcss = function(_, opts)
                local tw = require("lspconfig.server_configurations.tailwindcss")
                opts.filetypes = opts.filetypes or {}

                -- Add default filetypes
                vim.list_extend(opts.filetypes, tw.default_config.filetypes)

                -- Remove excluded filetypes
                --- @param ft string
                opts.filetypes = vim.tbl_filter(function(ft)
                    return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
                end, opts.filetypes)

                -- Add additional filetypes
                vim.list_extend(opts.filetypes, opts.filetypes_include or {})
            end,
        },
    },
}
