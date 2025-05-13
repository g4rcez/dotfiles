return {
    {
        "onsails/lspkind.nvim",
        {
            "saghen/blink.cmp",
            dependencies = { "rafamadriz/friendly-snippets", "nvim-lua/plenary.nvim", "L3MON4D3/LuaSnip" },
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
                fuzzy = { use_frecency = true, use_proximity = true },
                appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = true },
                signature = { enabled = true },
                cmdline = { keymap = { preset = "default" } },
                completion = {
                    keyword = { range = "full" },
                    menu = { auto_show = false },
                    documentation = { auto_show = false },
                    list = { selection = { preselect = true, auto_insert = true } },
                },
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
