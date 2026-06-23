local enabledFtMarkdown = { "markdown", "json", "text", "txt", "gitcommit" }

return {
    {
        "not-manu/filemention.nvim",
        event = "InsertEnter",
        opts = {
            trigger = "@",
            root = "git",
            respect_gitignore = true,
            include_hidden = false,
            format = "bare",
            filetypes = enabledFtMarkdown,
            max_items = 500,
            finder = "auto",
        },
    },
    {
        "newtoallofthis123/blink-cmp-fuzzy-path",
        dependencies = { "saghen/blink.cmp" },
        opts = {
            max_results = 10,
            search_tool = "fd",
            trigger_char = "@",
            search_hidden = true,
            relative_paths = true,
            filetypes = enabledFtMarkdown,
        },
    },
    {
        cond = not require("config.vscode").isVscode(),
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "saghen/blink.lib",
            "onsails/lspkind.nvim",
            "nvim-lua/plenary.nvim",
            "Kaiser-Yang/blink-cmp-git",
            "rafamadriz/friendly-snippets",
            "kristijanhusak/vim-dadbod-completion",
            { "L3MON4D3/LuaSnip", version = "v2.*" },
            "disrupted/blink-cmp-conventional-commits",
        },
        opts_extend = {
            "sources.completion.enabled_providers",
            "sources.compat",
            "sources.default",
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            fuzzy = {
                implementation = "rust",
                sorts = { "score", "exact", "sort_text", "label" },
            },
            signature = { enabled = false, window = { border = "single" } },
            appearance = { nerd_font_variant = "mono" },
            cmdline = {
                keymap = { preset = "default" },
                completion = {
                    ghost_text = { enabled = true },
                    list = { selection = { preselect = true } },
                    menu = {
                        auto_show = function()
                            return vim.fn.getcmdtype() == ":"
                        end,
                    },
                },
            },
            completion = {
                keyword = { range = "full" },
                ghost_text = { enabled = true },
                trigger = { show_in_snippet = false, prefetch_on_insert = true, show_on_insert = true },
                list = {
                    cycle = { from_bottom = true, from_top = true },
                    selection = { preselect = true, auto_insert = true },
                },
                accept = {
                    create_undo_point = true,
                    auto_brackets = {
                        enabled = true,
                        kind_resolution = {
                            enabled = true,
                            blocked_filetypes = { "typescriptreact", "vue", "javascriptreact" },
                        },
                    },
                },
                menu = {
                    min_width = 40,
                    auto_show = true,
                    border = "rounded",
                    auto_show_delay_ms = 200,
                    draw = { treesitter = { "lsp" }, padding = 1 },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    treesitter_highlighting = true,
                    window = { border = "single" },
                },
            },
            keymap = {
                preset = "super-tab",
                ["<Tab>"] = { "select_and_accept", "fallback" },
                ["<C-c>"] = { "hide", "fallback" },
                ["<C-y>"] = { "select_and_accept" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-/>"] = { "show_signature", "fallback" },
                ["<CR>"] = { "select_and_accept", "fallback" },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
            },
            sources = {
                default = { "lsp", "path", "dadbod", "buffer" },
                per_filetype = {
                    lua = { inherit_defaults = true, "lazydev" },
                    txt = { inherit_defaults = true, "git", "conventional_commits", "fuzzy-path" },
                    json = { inherit_defaults = true, "git", "conventional_commits", "fuzzy-path" },
                    text = { inherit_defaults = true, "git", "conventional_commits", "fuzzy-path" },
                    markdown = { inherit_defaults = true, "git", "conventional_commits", "fuzzy-path" },
                    gitcommit = { inherit_defaults = true, "git", "conventional_commits", "fuzzy-path" },
                },
                providers = {
                    buffer = { min_keyword_length = 4 },
                    snippets = { min_keyword_length = 3, score_offset = -100 },
                    git = { module = "blink-cmp-git", name = "Git", opts = {} },
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    filemention = { name = "filemention", module = "filemention.sources.blink" },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                    ["fuzzy-path"] = { name = "Fuzzy Path", module = "blink-cmp-fuzzy-path", score_offset = 0 },
                    conventional_commits = { name = "Conventional Commits", module = "blink-cmp-conventional-commits", opts = {} },
                },
            },
        },
    },
}
