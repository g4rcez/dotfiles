return {
    {
        "onsails/lspkind.nvim",
        {
            "saghen/blink.cmp",
            dependencies = { "rafamadriz/friendly-snippets", "nvim-lua/plenary.nvim" },
            version = "*",
            ---@module 'blink.cmp'
            ---@type blink.cmp.Config
            opts = {
                keymap = {
                    preset = "super-tab",
                    ["<CR>"] = { "accept", "fallback" },
                    ["<C-k>"] = { "select_prev", "fallback" },
                    ["<C-j>"] = { "select_next", "fallback" },
                    ["<C-space>"] = {
                        function(cmp)
                            cmp.show()
                        end,
                    },
                },
                appearance = {
                    nerd_font_variant = "mono",
                    use_nvim_cmp_as_default = false,
                },
                cmdline = {
                    keymap = {
                        preset = "default",
                    },
                },
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
                        omni = {
                            name = "Omni",
                            module = "blink.cmp.sources.omni",
                            opts = {
                                disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },
                            },
                        },
                    },
                },
                completion = {
                    accept = {
                        auto_brackets = { enabled = true }
                    },
                    keyword = { range = "full" },
                    ghost_text = { enabled = true },
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 200,
                        window = { border = "rounded" },
                        treesitter_highlighting = true,
                    },
                    menu = {
                        border = "rounded",
                        draw = {
                            padding = 1,
                            gap = 1,
                            treesitter = { 'lsp' },
                            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
                            components = {
                                kind_icon = {
                                    ellipsis = false,
                                    text = function(ctx)
                                        return ctx.kind_icon .. ctx.icon_gap
                                    end,
                                    highlight = function(ctx)
                                        local success, module = pcall(require,
                                            "blink.cmp.completion.windows.render.tailwind")
                                        local h = "BlinkCmpKind" .. ctx.kind
                                        if not success then
                                            return h
                                        end
                                        return module.get_hl(ctx) or h
                                    end,
                                },
                                kind = {
                                    ellipsis = false,
                                    width = { fill = true },
                                    text = function(ctx)
                                        return ctx.kind
                                    end,
                                    highlight = function(ctx)
                                        local success, module = pcall(require,
                                            "blink.cmp.completion.windows.render.tailwind")
                                        local h = "BlinkCmpKind" .. ctx.kind
                                        if not success then
                                            return h
                                        end
                                        return module.get_hl(ctx) or h
                                    end
                                },
                                label = {
                                    width = { fill = true, max = 60 },
                                    text = function(ctx)
                                        return ctx.label .. ctx.label_detail
                                    end,
                                    highlight = function(ctx)
                                        local highlights = {
                                            {
                                                0,
                                                #ctx.label,
                                                group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
                                            },
                                        }
                                        if ctx.label_detail then
                                            table.insert(highlights, {
                                                #ctx.label,
                                                #ctx.label + #ctx.label_detail,
                                                group = "BlinkCmpLabelDetail",
                                            })
                                        end
                                        for _, idx in ipairs(ctx.label_matched_indices) do
                                            table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                                        end
                                        return highlights
                                    end,
                                },

                                label_description = {
                                    width = { max = 30 },
                                    text = function(ctx)
                                        return ctx.label_description
                                    end,
                                    highlight = "BlinkCmpLabelDescription",
                                },
                                source_name = {
                                    width = { max = 30 },
                                    text = function(ctx)
                                        return ctx.source_name
                                    end,
                                    highlight = "BlinkCmpSource",
                                },
                            },
                        },
                    },
                },
                signature = {
                    enabled = true,
                    window = { border = "rounded" },
                    trigger = {
                        enabled = true,
                        show_on_keyword = true,
                        blocked_trigger_characters = {},
                        blocked_retrigger_characters = {},
                        show_on_trigger_character = true,
                        show_on_insert = false,
                        show_on_insert_on_trigger_character = true,
                    },
                },
            },
        },
    }
}
