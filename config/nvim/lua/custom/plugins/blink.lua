return {
    {
        "onsails/lspkind.nvim",
        {
            "saghen/blink.cmp",
            dependencies = { "rafamadriz/friendly-snippets", "nvim-lua/plenary.nvim" },
            ---@module 'blink.cmp'
            ---@type blink.cmp.Config
            opts = {
                keymap = {
                    preset = "enter",
                    ["<CR>"] = { "accept", "fallback" },
                    ["<C-k>"] = { "select_prev", "fallback" },
                    ["<C-j>"] = { "select_next", "fallback" },
                    ["<C-space>"] = {
                        function(cmp)
                            cmp.show()
                        end,
                    },
                },
                fuzzy = {
                    use_frecency = true,
                    use_proximity = true,
                    implementation = 'lua',
                    sorts = { "exact", "score", "sort_text" },
                },
                appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = false },
                cmdline = { keymap = { preset = "default" } },
                sources = {
                    default = { "lsp", "lazydev", "path", "snippets", "buffer" },
                    providers = {
                        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                        lsp = {
                            name = "LSP",
                            module = "blink.cmp.sources.lsp",
                            fallbacks = {},
                            enabled = true,
                            async = true,
                            timeout_ms = 2000,
                            should_show_items = true,
                            max_items = nil,
                            min_keyword_length = 0,
                            transform_items = function(_, items)
                                return vim.tbl_filter(function(item)
                                    return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
                                end, items)
                            end,
                        },
                        path = {
                            name = "Path",
                            module = "blink.cmp.sources.path",
                            score_offset = 3,
                            fallbacks = { "buffer" },
                            opts = {
                                trailing_slash = true,
                                label_trailing_slash = true,
                                get_cwd = function(context)
                                    return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                                end,
                                show_hidden_files_by_default = true,
                            },
                        },
                        snippets = {
                            name = "Snippets",
                            module = "blink.cmp.sources.snippets",
                            opts = {
                                friendly_snippets = true,
                                search_paths = { vim.fn.stdpath "config" .. "/snippets" },
                                global_snippets = { "all" },
                                extended_filetypes = {},
                                ignored_filetypes = {},
                                clipboard_register = nil,
                                get_filetype = function()
                                    return vim.bo.filetype
                                end,
                            },
                        },
                        buffer = {
                            name = "Buffer",
                            module = "blink.cmp.sources.buffer",
                            opts = {
                                get_bufnrs = function()
                                    return vim.iter(vim.api.nvim_list_wins())
                                        :map(function(win)
                                            return vim.api.nvim_win_get_buf(win)
                                        end)
                                        :filter(function(buf)
                                            return vim.bo[buf].buftype ~= "nofile"
                                        end)
                                        :totable()
                                end,
                            },
                        },
                    },
                },
                completion = {
                    keyword = { range = "full" },
                    ghost_text = {
                        enabled = true,
                        show_with_menu = true,
                        show_without_menu = true,
                        show_with_selection = true,
                        show_without_selection = false,
                    },
                    accept = {
                        auto_brackets = {
                            enabled = true,
                            kind_resolution = { enabled = true },
                            semantic_token_resolution = { enabled = true, timeout_ms = 400 }
                        },
                    },
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 200,
                        update_delay_ms = 100,
                        window = { border = "rounded" },
                        treesitter_highlighting = true,
                    },
                    menu = {
                        border = "rounded",
                        auto_show = false,
                        draw = { treesitter = { "lsp" } }
                    }
                },
                signature = {
                    enabled = true,
                    window = { border = "rounded" },
                    trigger = {
                        enabled = true,
                        show_on_insert = false,
                        show_on_keyword = true,
                        blocked_trigger_characters = {},
                        show_on_trigger_character = true,
                        blocked_retrigger_characters = {},
                        show_on_insert_on_trigger_character = true,
                    }
                }
            }
        }
    }
}
