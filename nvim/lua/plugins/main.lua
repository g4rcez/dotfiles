return {
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    {
        "vuki656/package-info.nvim",
        requires = "MunifTanjim/nui.nvim",
        opts = {
            colors = {
                up_to_date = "#3C4048", -- Text color for up to date dependency virtual text
                outdated = "#d19a66", -- Text color for outdated dependency virtual text
            },
            icons = {
                enable = true, -- Whether to display icons
                style = {
                    up_to_date = "|  ", -- Icon for up to date dependencies
                    outdated = "|  ", -- Icon for outdated dependencies
                },
            },
            autostart = true, -- Whether to autostart when `package.json` is opened
            hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
            hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
            -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
            -- The plugin will try to auto-detect the package manager based on
            -- `yarn.lock` or `package-lock.json`. If none are found it will use the
            -- provided one, if nothing is provided it will use `yarn`
            package_manager = "pnpm",
        },
    },
    {
        "folke/trouble.nvim",
        opts = { use_diagnostic_signs = true },
    },
    -- add symbols-outline
    {
        "simrat39/symbols-outline.nvim",
        cmd = "SymbolsOutline",
        keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
        config = true,
    },

    -- override nvim-cmp and add cmp-emoji
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-emoji" },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))
        end,
    },
    -- change some telescope options and a keymap to browse plugin files
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            {
                "<leader>fp",
                function()
                    require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
                end,
                desc = "Find Plugin File",
            },
        },
        -- change some options
        opts = {
            defaults = {
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
            },
        },
    },
    {
        "telescope.nvim",
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            config = function()
                require("telescope").load_extension("fzf")
            end,
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "tsx",
                "typescript",
                "vim",
                "yaml",
            },
        },
    },

    -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
    -- would overwrite `ensure_installed` with the new value.
    -- If you'd rather extend the default config, use the code below instead:
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- add tsx and treesitter
            vim.list_extend(opts.ensure_installed, {
                "tsx",
                "typescript",
            })

            local function add(lang)
                if type(opts.ensure_installed) == "table" then
                    table.insert(opts.ensure_installed, lang)
                end
            end
            add("git_config")
        end,
    },
    -- then: setup supertab in cmp
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-emoji",
        },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            local luasnip = require("luasnip")
            local cmp = require("cmp")

            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local format_kinds = opts.formatting.format
            opts.formatting.format = function(entry, item)
                format_kinds(entry, item) -- add icons
                return require("tailwindcss-colorizer-cmp").formatter(entry, item)
            end

            opts.mapping = vim.tbl_extend("force", opts.mapping, {
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                    -- this way you will only jump inside the snippet region
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            })
        end,
    },
    {
        "stevearc/aerial.nvim",
        event = "LazyFile",
        opts = function()
            local icons = vim.deepcopy(Config.icons.kinds)

            -- HACK: fix lua's weird choice for `Package` for control
            -- structures like if/else/for/etc.
            icons.lua = { Package = icons.Control }

            ---@type table<string, string[]>|false
            local filter_kind = false
            if Config.kind_filter then
                filter_kind = assert(vim.deepcopy(Config.kind_filter))
                filter_kind._ = filter_kind.default
                filter_kind.default = nil
            end

            local opts = {
                attach_mode = "global",
                backends = { "lsp", "treesitter", "markdown", "man" },
                show_guides = true,
                layout = {
                    resize_to_content = false,
                    win_opts = {
                        winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
                        signcolumn = "yes",
                        statuscolumn = " ",
                    },
                },
                icons = icons,
                filter_kind = filter_kind,
      -- stylua: ignore
      guides = {
        mid_item   = "├╴",
        last_item  = "└╴",
        nested_top = "│ ",
        whitespace = "  ",
      },
            }
            return opts
        end,
        keys = {
            { "<leader>ss", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
        },
    },
}
