return {
    "onsails/lspkind.nvim",
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "nvim-lua/plenary.nvim",
            { "L3MON4D3/LuaSnip", version = "v2.*" },
            "Kaiser-Yang/blink-cmp-avante",
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
                implementation = "lua",
            },
            appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = true },
            signature = { enabled = true },
            cmdline = { keymap = { preset = "default" } },
            completion = {
                ghost_text = { enabled = false },
                keyword = { range = "full" },
                menu = {
                    auto_show = false,
                    draw = {
                        treesitter = { "lsp" },
                    },
                },
                documentation = { auto_show = false },
                list = { selection = { preselect = true, auto_insert = true } },
            },
            keymap = {
                preset = "enter",
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "accept", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-space>"] = {
                    function(cmp)
                        cmp.show()
                    end,
                },
            },
            sources = {
                default = { "avante", "lsp", "path", "buffer", "snippets" },
                providers = {
                    avante = {
                        module = "blink-cmp-avante",
                        name = "Avante",
                        opts = {},
                    },
                },
            },
        },
    },
}
