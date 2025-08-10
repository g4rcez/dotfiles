return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "onsails/lspkind.nvim",
            "bydlw98/blink-cmp-env",
            "nvim-lua/plenary.nvim",
            "Kaiser-Yang/blink-cmp-git",
            "rafamadriz/friendly-snippets",
            { "L3MON4D3/LuaSnip", version = "v2.*" },
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        config = function(_, opts)
            require("blink.cmp").setup(opts)
            vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
        end,
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            snippets = { preset = "luasnip" },
            fuzzy = {
                use_frecency = true,
                use_proximity = true,
                implementation = "rust",
                sorts = {
                    function(a, b)
                        if (a.client_name == nil or b.client_name == nil) or (a.client_name == b.client_name) then
                            return
                        end
                        return b.client_name == "emmet_ls"
                    end,
                    "exact",
                    "score",
                    "sort_text",
                    "label",
                },
            },
            appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = true },
            signature = { enabled = true },
            cmdline = {
                keymap = { preset = "default" },
                sources = function()
                    local type = vim.fn.getcmdtype()
                    if type == "/" or type == "?" then return { "buffer" } end
                    if type == ":" then return { "cmdline" } end
                    return {}
                end,
            },
            completion = {
                list = {
                    selection = { preselect = false, auto_insert = false },
                    max_items = 50,
                },
                ghost_text = { enabled = false },
                keyword = { range = "full" },
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
            },
            keymap = {
                preset = "enter",
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "accept", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-y>"] = { "select_and_accept" },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
                providers = {
                    lsp = {
                        name = "LSP",
                        module = "blink.cmp.sources.lsp",
                        enabled = true,
                        transform_items = function(_, items)
                            return vim.tbl_filter(function(item)
                                local kind = item.kind
                                local types = require("blink.cmp.types").CompletionItemKind
                                return kind ~= types.Keyword
                                    and kind ~= types.Text
                                    and kind ~= types.Operator
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
                                return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
                            end,
                            show_hidden_files_by_default = false,
                        }
                    },
                    snippets = {
                        name = "Snippets",
                        module = "blink.cmp.sources.snippets",
                        score_offset = -1,
                        opts = {
                            friendly_snippets = true,
                            search_paths = { vim.fn.stdpath("config") .. "/snippets" },
                            global_snippets = { "all" },
                            extended_filetypes = {},
                            ignored_filetypes = {},
                        }
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
                        }
                    },
                },
            },
        },
    },
}
