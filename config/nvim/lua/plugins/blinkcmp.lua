local enabledFtMarkdown = { "markdown", "json", "text", "txt", "gitcommit" }
local denyList = { "markdown", "text", "txt" }

return {
    {
        "not-manu/filemention.nvim",
        event = "InsertEnter",
        opts = {
            root = "git",
            trigger = "@",
            finder = "auto",
            format = "bare",
            max_items = 500,
            include_hidden = false,
            respect_gitignore = true,
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
            snippets = { preset = "default" },
            signature = { enabled = true, window = { border = "single" } },
            fuzzy = {
                use_proximity = true,
                implementation = "rust",
                frecency = { enabled = true },
                sorts = { "score", "exact", "label", "sort_text" },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
                kind_icons = {
                    Text = "",
                    Method = "",
                    Function = "",
                    Constructor = "",
                    Field = "",
                    Variable = "",
                    Class = "",
                    Interface = "",
                    Module = "",
                    Property = "",
                    Unit = "",
                    Value = "",
                    Enum = "",
                    Keyword = "",
                    Snippet = "",
                    Color = "",
                    File = "",
                    Reference = "",
                    Folder = "",
                    EnumMember = "",
                    Constant = "",
                    Struct = "",
                    Event = "",
                    Operator = "",
                    TypeParameter = "",
                },
            },
            cmdline = {
                enabled = true,
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
                keyword = { range = "prefix" },
                ghost_text = { enabled = true },
                trigger = { show_in_snippet = false, prefetch_on_insert = true, show_on_insert = true },
                list = {
                    cycle = { from_bottom = true, from_top = true },
                    selection = { preselect = true, auto_insert = false },
                },
                accept = {
                    dot_repeat = false,
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
                    auto_show = function(ctx)
                        return not vim.tbl_contains(denyList, vim.bo[ctx.bufnr].filetype)
                    end,
                    border = "single",
                    auto_show_delay_ms = 0,
                    draw = {
                        padding = 1,
                        treesitter = { "lsp" },
                        columns = {
                            { "kind_icon" },
                            { "label", "label_description", gap = 1 },
                            { "kind", gap = 1 },
                        },
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 250,
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
                default = { "lsp", "contextual", "path", "dadbod", "snippets", "buffer" },
                per_filetype = {
                    ["pi-prompt"] = { "pi_bridge" },
                    lua = { inherit_defaults = true, "lazydev" },
                    json = { inherit_defaults = true, "git", "filemention" },
                    txt = { inherit_defaults = true, "git", "conventional_commits", "filemention" },
                    text = { inherit_defaults = true, "git", "conventional_commits", "filemention" },
                    markdown = { inherit_defaults = true, "git", "conventional_commits", "filemention" },
                    gitcommit = { inherit_defaults = true, "git", "conventional_commits", "filemention" },
                },
                providers = {
                    pi_bridge = { name = "Pi", module = "pi-bridge.blink_source", async = true },
                    contextual = {
                        name = "Context",
                        module = "config.contextual_completion",
                        score_offset = 80,
                        max_items = 2,
                    },
                    lsp = { name = "LSP" },
                    path = { name = "Path", opts = { show_hidden_files_by_default = true } },
                    git = {
                        module = "blink-cmp-git",
                        name = "Git",
                        opts = {
                            commit = {
                                triggers = { '' },
                            },
                        },
                    },
                    dadbod = { name = "DB", module = "vim_dadbod_completion.blink" },
                    buffer = { name = "Buf", min_keyword_length = 5, score_offset = -5 },
                    filemention = { name = "File", module = "filemention.sources.blink" },
                    snippets = { name = "Snip", min_keyword_length = 3, score_offset = 0 },
                    lazydev = { name = "Lua", module = "lazydev.integrations.blink", score_offset = 100 },
                    conventional_commits = { name = "Commit", module = "blink-cmp-conventional-commits", opts = {} },
                },
            },
        },
    },
}
