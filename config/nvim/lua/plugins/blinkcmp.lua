return {
    {
        "newtoallofthis123/blink-cmp-fuzzy-path",
        dependencies = { "saghen/blink.cmp" },
        opts = {
            max_results = 20,
            trigger_char = "@",
            search_hidden = true,
            relative_paths = true,
            filetypes = { "markdown", "json", "text" },
        },
    },
    {
        cond = not require("config.vscode").isVscode(),
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {
            bind = true,
            handler_opts = {
                border = "rounded",
            },
        },
    },
    {
        cond = not require("config.vscode").isVscode(),
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
        cond = not require("config.vscode").isVscode(),
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "onsails/lspkind.nvim",
            "nvim-lua/plenary.nvim",
            "Kaiser-Yang/blink-cmp-git",
            "rafamadriz/friendly-snippets",
            "Kaiser-Yang/blink-cmp-dictionary",
            "kristijanhusak/vim-dadbod-completion",
            { "L3MON4D3/LuaSnip", version = "v2.*" },
            "disrupted/blink-cmp-conventional-commits",
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            fuzzy = {
                implementation = "prefer_rust",
                sorts = {
                    function(a, b)
                        if (a.client_name == nil or b.client_name == nil) or (a.client_name == b.client_name) then return end
                        return b.client_name == "emmet_ls"
                    end,
                    "exact",
                    "score",
                    "sort_text",
                    "label",
                },
            },
            signature = { enabled = true },
            snippets = { preset = "luasnip" },
            appearance = { nerd_font_variant = "mono" },
            cmdline = {
                keymap = { preset = "super-tab" },
                completion = {
                    ghost_text = { enabled = true },
                    list = { selection = { preselect = false } },
                    menu = {
                        auto_show = function()
                            return vim.fn.getcmdtype() == ":"
                        end,
                    },
                },
            },
            completion = {
                trigger = { show_in_snippet = false, prefetch_on_insert = true, show_on_insert = true },
                list = {
                    cycle = { from_bottom = true, from_top = true },
                    selection = { preselect = false, auto_insert = true },
                },
                keyword = { range = "full" },
                ghost_text = { enabled = true },
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
                    enabled = true,
                    auto_show = true,
                    border = "single",
                    draw = { treesitter = { "lsp" }, padding = 2 },
                },
                documentation = {
                    auto_show = true,
                    treesitter_highlighting = true,
                    window = { border = "single" },
                },
            },
            keymap = {
                preset = "default",
                ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
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
                show_in_snippet = true,
                default = {
                    "snippets",
                    "fuzzy-path",
                    "lazydev",
                    "lsp",
                    "git",
                    "path",
                    "conventional_commits",
                    "dadbod",
                    "buffer",
                    "dictionary",
                },
                providers = {
                    git = { module = "blink-cmp-git", name = "Git", opts = {} },
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    dictionary = { name = "Dict", min_keyword_length = 3, module = "blink-cmp-dictionary" },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                    ["fuzzy-path"] = { name = "Fuzzy Path", module = "blink-cmp-fuzzy-path", score_offset = 0 },
                    conventional_commits = {
                        name = "Conventional Commits",
                        module = "blink-cmp-conventional-commits",
                        enabled = function()
                            return vim.bo.filetype == "gitcommit"
                        end,
                        opts = {},
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
