return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        keys = {
            {
                "<C-r>s",
                function()
                    require("luasnip.extras.otf").on_the_fly "s"
                end,
                desc = "Insert on-the-fly snippet",
                mode = "i",
            },
        },
        opts = function()
            local types = require "luasnip.util.types"
            require("luasnip.loaders.from_vscode").lazy_load()
            return {
                delete_check_events = "TextChanged",
                ext_opts = {
                    [types.insertNode] = {
                        unvisited = {
                            virt_text = { { "|", "Conceal" } },
                            virt_text_pos = "inline",
                        },
                    },
                    [types.exitNode] = {
                        unvisited = {
                            virt_text = { { "|", "Conceal" } },
                            virt_text_pos = "inline",
                        },
                    },
                    [types.choiceNode] = {
                        active = {
                            virt_text = { { "(snippet) choice node", "LspInlayHint" } },
                        },
                    },
                },
            }
        end,
        config = function(_, opts)
            local luasnip = require "luasnip"
            ---@diagnostic disable: undefined-field
            luasnip.setup(opts)
            require("luasnip.loaders.from_vscode").lazy_load {
                paths = vim.fn.stdpath "config" .. "/snippets",
            }
            vim.keymap.set({ "i", "s" }, "<C-c>", function()
                if luasnip.choice_active() then
                    require "luasnip.extras.select_choice"()
                end
            end, { desc = "Select choice" })
        end,
    },
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
            "kristijanhusak/vim-dadbod-completion",
            { "L3MON4D3/LuaSnip", version = "v2.*" },
            "disrupted/blink-cmp-conventional-commits",
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            signature = { enabled = true },
            snippets = { preset = "luasnip" },
            fuzzy = { implementation = "rust" },
            appearance = { nerd_font_variant = "mono" },
            cmdline = {
                keymap = { preset = "default" },
                keymap = {
                    preset = "cmdline",
                    ["<Right>"] = false,
                    ["<Left>"] = false,
                },
                completion = {
                    list = { selection = { preselect = false } },
                    menu = {
                        auto_show = function(ctx)
                            return vim.fn.getcmdtype() == ":"
                        end,
                    },
                    ghost_text = { enabled = true },
                },
            },
            completion = {
                trigger = { show_in_snippet = true, prefetch_on_insert = true, show_on_insert = true },
                list = {
                    max_items = 100,
                    cycle = { from_bottom = true, from_top = true },
                    selection = { preselect = false, auto_insert = true },
                },
                keyword = { range = "full" },
                ghost_text = { enabled = true, show_with_menu = false },
                accept = { create_undo_point = true, auto_brackets = { enabled = true } },
                menu = {
                    enabled = true,
                    auto_show = true,
                    border = "rounded",
                    auto_show_delay_ms = 300,
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    draw = {
                        treesitter = { "lsp" },
                        columns = {
                            { "kind_icon", "label", "label_description", gap = 1 },
                            { "kind", gap = 1 },
                        },
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    else
                                        icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
                                    end

                                    return icon .. ctx.icon_gap
                                end,
                                highlight = function(ctx)
                                    local hl = ctx.kind_hl
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    end
                                    return hl
                                end,
                            },
                        },
                    },
                },
                documentation = {
                    auto_show = true,
                    update_delay_ms = 60,
                    auto_show_delay_ms = 300,
                    treesitter_highlighting = true,
                    window = {
                        border = "rounded",
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    },
                },
            },
            keymap = {
                preset = "enter",
                ["<C-c>"] = { "hide", "fallback" },
                ["<C-y>"] = { "select_and_accept" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-/>"] = { "show_signature", "fallback" },
                ["<CR>"] = { "select_and_accept", "fallback" },
                ["<Tab>"] = { "select_and_accept", "fallback" },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
            },
            sources = {
                default = {
                    "lazydev",
                    "lsp",
                    "snippets",
                    "path",
                    "conventional_commits",
                    "dadbod",
                    "buffer",
                },
                providers = {
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                    conventional_commits = {
                        name = "Conventional Commits",
                        module = "blink-cmp-conventional-commits",
                        enabled = function()
                            return vim.bo.filetype == "gitcommit"
                        end,
                        opts = {},
                    },
                    css_vars = {
                        name = "css-vars",
                        module = "css-vars.blink",
                        opts = {
                            search_extensions = { ".js", ".ts", ".jsx", ".tsx" },
                        },
                    },
                    lsp = {
                        name = "LSP",
                        async = false,
                        enabled = true,
                        fallbacks = {},
                        override = nil,
                        max_items = nil,
                        score_offset = 10,
                        timeout_ms = 2000,
                        transform_items = nil,
                        min_keyword_length = 0,
                        should_show_items = true,
                        module = "blink.cmp.sources.lsp",
                    },
                },
            },
        },
    },
}
