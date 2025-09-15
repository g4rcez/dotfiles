return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "onsails/lspkind.nvim",
            "bydlw98/blink-cmp-env",
            "nvim-lua/plenary.nvim",
            "jdrupal-dev/css-vars.nvim",
            "Kaiser-Yang/blink-cmp-git",
            "rafamadriz/friendly-snippets",
            { "L3MON4D3/LuaSnip", version = "v2.*" },
            { "disrupted/blink-cmp-conventional-commits" },
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = function(_, opts)
            opts.snippets = { preset = "luasnip" }
            opts.fuzzy = {
                use_frecency = true,
                use_proximity = true,
                implementation = "rust",
                sorts = { "exact", "score", "sort_text", "label" },
            }
            opts.appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = true }
            opts.signature = { enabled = true }
            opts.cmdline = {
                keymap = { preset = "default" },
                sources = function()
                    local type = vim.fn.getcmdtype()
                    if type == "/" or type == "?" then
                        return { "buffer" }
                    end
                    if type == ":" then
                        return { "cmdline" }
                    end
                    return {}
                end,
            }
            opts.completion = {
                list = {
                    max_items = 50,
                    selection = { preselect = false, auto_insert = false },
                },
                keyword = { range = "full" },
                ghost_text = { enabled = true },
                accept = { create_undo_point = true, auto_brackets = { enabled = true } },
                menu = {
                    enabled = true,
                    auto_show = true,
                    border = "rounded",
                    draw = { treesitter = { "lsp" } },
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                },
                documentation = {
                    auto_show = false,
                    treesitter_highlighting = true,
                    window = {
                        border = "rounded",
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    },
                },
            }
            opts.keymap = {
                preset = "enter",
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-y>"] = { "select_and_accept" },
                ["<Tab>"] = { "select_and_accept", "fallback" },
                ["<S-Tab>"] = { "insert_prev" },
                ["<CR>"] = {
                    function(cmp)
                        if cmp.snippet_active() then
                            return cmp.cancel()
                        else
                            return cmp.select_and_accept()
                        end
                    end,
                    "snippet_forward",
                    "fallback",
                },
            }
            opts.sources = {
                default = { "conventional_commits", "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                    conventional_commits = {
                        name = "Conventional Commits",
                        module = "blink-cmp-conventional-commits",
                        enabled = function()
                            return vim.bo.filetype == "gitcommit"
                        end,
                        opts = {}, -- none so far
                    },
                    css_vars = {
                        name = "css-vars",
                        module = "css-vars.blink",
                        opts = {
                            -- WARNING: The search is not optimized to look for variables in JS files.
                            -- If you change the search_extensions you might get false positives and weird completion results.
                            search_extensions = { ".js", ".ts", ".jsx", ".tsx" },
                        },
                    },
                    lsp = {
                        name = "LSP",
                        module = "blink.cmp.sources.lsp",
                        enabled = true,
                        transform_items = function(_, items)
                            return vim.tbl_filter(function(item)
                                local kind = item.kind
                                local types = require("blink.cmp.types").CompletionItemKind
                                return kind ~= types.Keyword and kind ~= types.Text and kind ~= types.Operator
                            end, items)
                        end,
                    },
                    path = {
                        name = "Path",
                        module = "blink.cmp.sources.path",
                        score_offset = -3,
                        opts = {
                            trailing_slash = false,
                            label_trailing_slash = true,
                            get_cwd = function(context)
                                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                            end,
                            show_hidden_files_by_default = false,
                        },
                    },
                    snippets = {
                        name = "Snippets",
                        module = "blink.cmp.sources.snippets",
                        score_offset = -1,
                        opts = {
                            friendly_snippets = true,
                            search_paths = { vim.fn.stdpath "config" .. "/snippets" },
                            global_snippets = { "all" },
                            extended_filetypes = {},
                            ignored_filetypes = {},
                        },
                    },
                    buffer = {
                        name = "Buffer",
                        module = "blink.cmp.sources.buffer",
                        enabled = true,
                        score_offset = -5,
                        opts = {
                            max_items = 5,
                            get_bufnrs = function()
                                local bufs = {}
                                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                                    local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                                    if byte_size < 1024 * 1024 then -- 1MB limit
                                        table.insert(bufs, buf)
                                    end
                                end
                                return bufs
                            end,
                        },
                    },
                },
            }
            return opts
        end,
    },
}
