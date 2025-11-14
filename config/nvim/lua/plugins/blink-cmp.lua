return {
    {
        "newtoallofthis123/blink-cmp-fuzzy-path",
        dependencies = { "saghen/blink.cmp" },
        opts = {
            filetypes = { "markdown", "json" },
            trigger_char = "@",
            max_results = 5,
        },
    },
    {
        "saghen/blink.cmp",
        opts = {
            signature = { enabled = true },
            completion = {
                ghost_text = { enabled = true },
                menu = { draw = { treesitter = { "lsp" } } },
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            sources = {
                default = { "fuzzy-path", "lsp", "path", "snippets", "buffer" },
                providers = {
                    ["fuzzy-path"] = {
                        name = "Fuzzy Path",
                        module = "blink-cmp-fuzzy-path",
                        score_offset = 0,
                    },
                },
            },
            cmdline = {
                enabled = true,
                keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
                completion = {
                    ghost_text = { enabled = true },
                    list = { selection = { preselect = true } },
                },
            },
            keymap = {
                preset = "enter",
                ["<Right>"] = false,
                ["<Left>"] = false,
                ["<C-c>"] = { "hide", "fallback" },
                ["<C-y>"] = { "select_and_accept" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-/>"] = { "show_signature", "fallback" },
                ["<CR>"] = { "select_and_accept", "fallback" },
                ["<Tab>"] = { "select_and_accept", "fallback" },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },
            },
        },
    },
}
