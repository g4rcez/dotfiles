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
            cmdline = { keymap = { preset = "default" } },
            completion = {
                list = { selection = { preselect = true, auto_insert = true } },
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
                default = { "lsp", "path", "snippets" },
                providers = {
                    lsp = {
                        name = "LSP",
                        module = "blink.cmp.sources.lsp",
                        transform_items = function(_, items)
                            return vim.tbl_filter(function(item)
                                return item.kind ~= require("blink.cmp.types").CompletionItemKind.Keyword
                            end, items)
                        end,
                    },
                },
            },
        },
    },
}
