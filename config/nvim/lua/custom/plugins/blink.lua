return {
    {
        "onsails/lspkind.nvim",
        {
            "saghen/blink.cmp",
            dependencies = { "rafamadriz/friendly-snippets", "nvim-lua/plenary.nvim", "L3MON4D3/LuaSnip" },
            ---@module 'blink.cmp'
            ---@type blink.cmp.Config
            opts = {
                snippets = { preset = "luasnip" },
                fuzzy = { use_frecency = true, use_proximity = true, implementation = "lua" },
                appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = false },
                cmdline = { keymap = { preset = "default" } },
                completion = { documentation = { auto_show = false } },
                sources = { default = { "lsp", "path", "snippets", "buffer" } },
                keymap = {
                    preset = "enter",
                    ["<CR>"] = { "accept", "fallback" },
                    ["<Tab>"] = { "accept", "fallback" },
                    ["<C-k>"] = { "select_prev", "fallback" },
                    ["<C-j>"] = { "select_next", "fallback" },
                    ["<C-space>"] = {
                        function(cmp)
                            cmp.show()
                        end,
                    },
                },
            },
        },
    },
}
