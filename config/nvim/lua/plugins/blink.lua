return {
    {
        "rafamadriz/friendly-snippets",
        config = function(_, opts)
            local luasnip = require "luasnip"
            if opts then
                luasnip.config.setup(opts)
            end
            vim.tbl_map(function(type)
                require("luasnip.loaders.from_" .. type).lazy_load()
            end, { "vscode", "snipmate", "lua" })
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_vscode").lazy_load {
                paths = { vim.fn.stdpath "config" .. "/snippets" },
            }
            luasnip.filetype_extend("c", { "cdoc" })
            luasnip.filetype_extend("lua", { "luadoc" })
            luasnip.filetype_extend("sh", { "shelldoc" })
            luasnip.filetype_extend("cs", { "csharpdoc" })
            luasnip.filetype_extend("javascript", { "jsdoc" })
            luasnip.filetype_extend("typescript", { "tsdoc" })
        end,
    },
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "onsails/lspkind.nvim",
            "bydlw98/blink-cmp-env",
            "nvim-lua/plenary.nvim",
            "jdrupal-dev/css-vars.nvim",
            "Kaiser-Yang/blink-cmp-git",
            "rafamadriz/friendly-snippets",
            "kristijanhusak/vim-dadbod-completion",
            { "L3MON4D3/LuaSnip", version = "v2.*" },
            "disrupted/blink-cmp-conventional-commits",
        },
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            signature = { enabled = true },
            snippets = { preset = "luasnip" },
            fuzzy = { implementation = "rust" },
            appearance = { nerd_font_variant = "mono", use_nvim_cmp_as_default = true },
            cmdline = {
                keymap = { preset = "default" },
                sources = function()
                    local type = vim.fn.getcmdtype()
                    if type == "/" or type == "?" then
                        return { "buffer" }
                    end
                    if type == ":" then
                        return { "cmdline" }
                    end
                    return {}
                end,
            },
            completion = {
                list = {
                    max_items = 100,
                    cycle = { from_bottom = true, from_top = true },
                    selection = { preselect = false, auto_insert = true },
                },
                keyword = { range = "full" },
                ghost_text = { enabled = true, show_with_menu = false },
                accept = { create_undo_point = true, auto_brackets = { enabled = false } },
                menu = {
                    enabled = true,
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    border = "rounded",
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    draw = {
                        treesitter = { "lsp" },
                        columns = {
                            { "kind_icon", "label", "label_description", gap = 1 },
                            { "kind", gap = 1 },
                        },
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    else
                                        icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
                                    end

                                    return icon .. ctx.icon_gap
                                end,
                                highlight = function(ctx)
                                    local hl = ctx.kind_hl
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    end
                                    return hl
                                end,
                            },
                        },
                    },
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
                ["<C-/>"] = { "show_signature", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-c>"] = { "hide", "fallback" },
                ["<Esc>"] = { "cancel", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-y>"] = { "select_and_accept" },
                ["<Tab>"] = { "select_and_accept", "fallback" },
                ["<S-Tab>"] = { "insert_prev" },
                ["<CR>"] = {
                    function(cmp)
                        if cmp.snippet_active() then
                            return cmp.cancel()
                        else
                            return cmp.select_and_accept()
                        end
                    end,
                    "snippet_forward",
                    "fallback",
                },
            },
            sources = {
                default = {
                    "lsp",
                    "path",
                    "lazydev",
                    "conventional_commits",
                    "dadbod",
                    -- "buffer",
                    "snippets",
                },
                providers = {
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                    conventional_commits = {
                        name = "Conventional Commits",
                        module = "blink-cmp-conventional-commits",
                        enabled = function()
                            return vim.bo.filetype == "gitcommit"
                        end,
                        opts = {},
                    },
                    css_vars = {
                        name = "css-vars",
                        module = "css-vars.blink",
                        opts = {
                            search_extensions = { ".js", ".ts", ".jsx", ".tsx" },
                        },
                    },
                    lsp = {
                        name = "LSP",
                        module = "blink.cmp.sources.lsp",
                        enabled = true,
                        async = false,
                        timeout_ms = 2000,
                        transform_items = nil,
                        should_show_items = true,
                        max_items = nil,
                        min_keyword_length = 0,
                        fallbacks = {},
                        score_offset = 10,
                        override = nil,
                    },
                },
            },
        },
    },
    {
        "ph1losof/ecolog.nvim",
        keys = {
            { "<leader>cE", "<cmd>EcologGoto<cr>", desc = "[c]ode [E]env" },
            { "<leader>cp", "<cmd>EcologPeek<cr>", desc = "[c]ode [p]eek env" },
        },
        lazy = false,
        opts = {
            types = true,
            path = vim.fn.getcwd(),
            provider_patterns = true,
            integrations = { blink_cmp = true },
            preferred_environment = "development",
            shelter = {
                configuration = {
                    -- Partial mode configuration:
                    -- false: completely mask values (default)
                    -- true: use default partial masking settings
                    -- table: customize partial masking
                    -- partial_mode = false,
                    -- or with custom settings:
                    partial_mode = {
                        show_start = 3, -- Show first 3 characters
                        show_end = 3, -- Show last 3 characters
                        min_mask = 3, -- Minimum masked characters
                    },
                    mask_char = "*", -- Character used for masking
                    mask_length = nil, -- Optional: fixed length for masked portion (defaults to value length)
                    skip_comments = false, -- Skip masking comment lines in environment files (default: false)
                },
                modules = {
                    cmp = true, -- Enabled to mask values in completion
                    peek = false, -- Enable to mask values in peek view
                    files = true, -- Enabled to mask values in file buffers
                    telescope = false, -- Enable to mask values in telescope integration
                    telescope_previewer = false, -- Enable to mask values in telescope preview buffers
                    fzf = false, -- Enable to mask values in fzf picker
                    fzf_previewer = true, -- Enable to mask values in fzf preview buffers
                    snacks_previewer = false, -- Enable to mask values in snacks previewer
                    snacks = false, -- Enable to mask values in snacks picker
                },
            },
        },
    },
}
