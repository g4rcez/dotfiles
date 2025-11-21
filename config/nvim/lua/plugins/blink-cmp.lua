return {
    { "saghen/blink.compat", version = "*", lazy = true, opts = {} },
    {
        "newtoallofthis123/blink-cmp-fuzzy-path",
        dependencies = { "saghen/blink.cmp" },
        opts = {
            max_results = 10,
            trigger_char = "@",
            filetypes = { "markdown", "json", "commitmsg", "gitcommit" },
        },
    },
    {
        "Jezda1337/nvim-html-css",
        dependencies = { "saghen/blink.cmp", "nvim-treesitter/nvim-treesitter" },
        opts = {
            enable_on = { -- Example file types
                "html",
                "htmldjango",
                "tsx",
                "jsx",
                "erb",
                "svelte",
                "vue",
                "blade",
                "php",
                "templ",
                "astro",
                "typescriptreact",
            },
            handlers = {
                definition = { bind = "gd" },
                hover = { bind = "K", wrap = true, border = "none", position = "cursor" },
            },
            documentation = { auto_show = true },
            style_sheets = {
                "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
                "https://cdnjs.cloudflare.com/ajax/libs/bulma/1.0.3/css/bulma.min.css",
                "./src/index.css",
                "./src/styles/index.css",
                "./index.css",
            },
        },
    },
    {
        "saghen/blink.cmp",
        opts_extend = { "sources.default" },
        dependencies = { "fang2hou/blink-copilot" },
        opts = {
            signature = { enabled = true },
            completion = {
                ghost_text = { enabled = true },
                menu = { draw = { treesitter = { "lsp" } } },
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            sources = {
                default = { "fuzzy-path", "lsp", "path", "snippets", "html-css", "buffer" },
                providers = {
                    ["html-css"] = { name = "html-css", module = "blink.compat.source" },
                    ["fuzzy-path"] = { name = "Fuzzy Path", module = "blink-cmp-fuzzy-path", score_offset = 0 },
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
