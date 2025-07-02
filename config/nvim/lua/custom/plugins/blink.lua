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
            "Kaiser-Yang/blink-cmp-avante",
            "rafamadriz/friendly-snippets",
            "mikavilpas/blink-ripgrep.nvim",
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
            fuzzy = { use_frecency = true, use_proximity = true, implementation = "rust" },
            appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = true },
            signature = { enabled = true },
            cmdline = { keymap = { preset = "default" } },
            completion = {
                list = { selection = { preselect = true, auto_insert = true } },
                ghost_text = { enabled = false },
                keyword = { range = "full" },
                accept = { auto_brackets = { enabled = true } },
                menu = {
                    enabled = true,
                    auto_show = true,
                    border = "rounded",
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    draw = { treesitter = { "lsp" } },
                },
                documentation = {
                    auto_show = false,
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
                default = { "lsp", "avante", "snippets", "path", "git", "ripgrep", "buffer" },
                providers = {
                    git = {
                        module = "blink-cmp-git",
                        name = "Git",
                        opts = {},
                    },
                    avante = {
                        module = "blink-cmp-avante",
                        name = "Avante",
                        opts = {},
                    },
                    ripgrep = {
                        module = "blink-ripgrep",
                        name = "Ripgrep",
                        -- the options below are optional, some default values are shown
                        ---@module "blink-ripgrep"
                        ---@type blink-ripgrep.Options
                        opts = {
                            prefix_min_len = 3,
                            context_size = 5,
                            max_filesize = "1M",
                            project_root_marker = ".git",
                            project_root_fallback = true,
                            search_casing = "--smart-case",
                            additional_rg_options = {},
                            fallback_to_regex_highlighting = true,
                            ignore_paths = {},
                            additional_paths = {},
                            toggles = { on_off = nil, debug = nil },
                            future_features = {
                                backend = {
                                    use = "ripgrep",
                                    customize_icon_highlight = true,
                                },
                            },
                            debug = false,
                        },
                        transform_items = function(_, items)
                            for _, item in ipairs(items) do
                                item.labelDetails = { description = "(rg)" }
                            end
                            return items
                        end,
                    },
                },
            },
        },
    },
}
