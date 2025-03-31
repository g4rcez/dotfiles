local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "mattn/emmet-vim",
    "tpope/vim-sleuth",
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",
    "JoosepAlviste/nvim-ts-context-commentstring",
    { "numToStr/Comment.nvim", opts = {} },
    { "nvim-treesitter/nvim-treesitter-textobjects", dependencies = { "nvim-treesitter/nvim-treesitter" } },
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
            multiwindow = false, -- Enable multiwindow support.
            max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 20, -- Maximum number of lines to show for a single context
            trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
            separator = nil,
            zindex = 20, -- The Z-index of the context window
            on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    },
    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = true },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
    },
    {
        "axelvc/template-string.nvim",
        ft = fileTypes,
        event = "InsertEnter",
        opts = {
            filetypes = fileTypes,
            remove_template_string = true,
            restore_quotes = {
                normal = [[']],
                jsx = [["]],
            },
        },
    },
    {
        "andymass/vim-matchup",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = function(_, opts)
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
            require("nvim-treesitter.configs").setup { matchup = { enable = true } }
            return opts
        end,
    },
    {
        "Wansmer/treesj",
        opts = { use_default_keymaps = false },
        keys = { { "<leader>cJ", "<cmd>TSJToggle<cr>", desc = "[J]oin Toggle" } },
    },
    {
        "nmac427/guess-indent.nvim",
        opts = {
            auto_cmd = true,
            override_editorconfig = false,
        },
    },
    {
        "brenoprata10/nvim-highlight-colors",
        opts = {
            render = "background",
            virtual_symbol = "■",
            virtual_symbol_prefix = "",
            virtual_symbol_suffix = " ",
            virtual_symbol_position = "inline",
            enable_hex = true,
            enable_short_hex = true,
            enable_rgb = true,
            enable_hsl = true,
            enable_var_usage = true,
            enable_named_colors = true,
            enable_tailwind = true,
            exclude_filetypes = {},
            exclude_buftypes = {},
        },
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        opts = {
            filetypes = { "*" }, -- Filetype options.  Accepts table like `user_default_options`
            buftypes = {}, -- Buftype options.  Accepts table like `user_default_options`
            user_commands = true, -- Enable all or some usercommands
            lazy_load = false, -- Lazily schedule buffer highlighting setup function
            user_default_options = {
                names = true, -- "Name" codes like Blue or red.  Added from `vim.api.nvim_get_color_map()`
                names_opts = { -- options for mutating/filtering names.
                    lowercase = true, -- name:lower(), highlight `blue` and `red`
                    camelcase = true, -- name, highlight `Blue` and `Red`
                    uppercase = true, -- name:upper(), highlight `BLUE` and `RED`
                    strip_digits = false, -- ignore names with digits,
                    -- highlight `blue` and `red`, but not `blue3` and `red4`
                },
                names_custom = false,
                RGB = true, -- #RGB hex codes
                RGBA = true, -- #RGBA hex codes
                RRGGBB = true, -- #RRGGBB hex codes
                RRGGBBAA = true, -- #RRGGBBAA hex codes
                AARRGGBB = true, -- 0xAARRGGBB hex codes
                rgb_fn = true, -- CSS rgb() and rgba() functions
                hsl_fn = true, -- CSS hsl() and hsla() functions
                css = true, -- Enable all CSS *features*:
                -- names, RGB, RGBA, RRGGBB, RRGGBBAA, AARRGGBB, rgb_fn, hsl_fn
                css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
                -- Tailwind colors.  boolean|'normal'|'lsp'|'both'.  True sets to 'normal'
                tailwind = "both", -- Enable tailwind colors
                tailwind_opts = { -- Options for highlighting tailwind names
                    update_names = "both", -- When using tailwind = 'both', update tailwind names from LSP results.  See tailwind section
                },
                -- parsers can contain values used in `user_default_options`
                sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
                -- Highlighting mode.  'background'|'foreground'|'virtualtext'
                mode = "virtualtext", -- Set the display mode
                -- Virtualtext character to use
                virtualtext = "■",
                -- Display virtualtext inline with color.  boolean|'before'|'after'.  True sets to 'after'
                virtualtext_inline = "before",
                -- Virtualtext highlight mode: 'background'|'foreground'
                virtualtext_mode = "foreground",
                -- update color values even if buffer is not focused
                -- example use: cmp_menu, cmp_docs
                always_update = true,
                -- hooks to invert control of colorizer
                hooks = {
                    -- called before line parsing.  Set to function that returns a boolean and accepts the following parameters.  See hooks section.
                    do_lines_parse = false,
                },
            },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-ts-autotag").setup {
                opts = {
                    enable_close = true, -- Auto close tags
                    enable_rename = true, -- Auto rename pairs of tags
                    enable_close_on_slash = true, -- Auto close on trailing </
                },
            }
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },
    {
        "stevearc/pair-ls.nvim",
        config = true,
        cmd = { "Pair", "PairConnect" },
        opts = { cmd = { "pair-ls", "lsp" } },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "c_sharp",
                "css",
                "csv",
                "diff",
                "dockerfile",
                "git_config",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "html",
                "http",
                "javascript",
                "jq",
                "json",
                "json5",
                "kdl",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "prisma",
                "query",
                "regex",
                "styled",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
                "zig",
            },
            auto_install = true,
            sync_install = true,
            indent = { enable = true },
            highlight = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    scope_incremental = false,
                    node_incremental = "<Enter>",
                    node_decremental = "<Backspace>",
                    init_selection = "<Enter>", -- set to `false` to disable one of the mappings
                },
            },
        },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = function(_, opts)
            local ts = { "prettierd", "prettier", stop_after_first = true }
            opts.notify_no_formatters = true
            opts.default_format_opts = {
                lsp_format = "fallback",
            }
            opts.formatters_by_ft = {
                lua = { "stylua" },
                -- Conform will run multiple formatters sequentially
                python = { "isort", "black" },
                -- You can customize some of the format options for the filetype (:help conform.format)
                rust = { "rustfmt", lsp_format = "fallback" },
                -- Conform will run the first available formatter
                css = ts,
                html = ts,
                json = ts,
                yaml = ts,
                svelte = ts,
                graphql = ts,
                markdown = ts,
                javascript = ts,
                typescript = ts,
                javascriptreact = ts,
                typescriptreact = ts,
            }
            return opts
        end,
    },
    {
        "nvimdev/lspsaga.nvim",
        opts = {
            lightbulb = { enable = false, virtual_text = false },
            finder = { max_height = 0.8, keys = { vsplit = "v" } },
            ui = { enable = false, code_action = "", border = "rounded" },
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional
            "nvim-tree/nvim-web-devicons", -- optional
        },
    },
    {
        enabled = false,
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            events = { "BufWritePost", "BufReadPost", "InsertLeave" },
            linters = {},
            linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
            },
        },
        config = function(_, opts)
            local M = {}
            local lint = require "lint"
            for name, linter in pairs(opts.linters) do
                if type(linter) == "table" and type(lint.linters[name]) == "table" then
                    lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
                    if type(linter.prepend_args) == "table" then
                        lint.linters[name].args = lint.linters[name].args or {}
                        vim.list_extend(lint.linters[name].args, linter.prepend_args)
                    end
                else
                    lint.linters[name] = linter
                end
            end
            lint.linters_by_ft = opts.linters_by_ft
            function M.debounce(ms, fn)
                local timer = vim.uv.new_timer()
                return function(...)
                    local argv = { ... }
                    timer:start(ms, 0, function()
                        timer:stop()
                        vim.schedule_wrap(fn)(unpack(argv))
                    end)
                end
            end
            function M.lint()
                local names = lint._resolve_linter_by_ft(vim.bo.filetype)
                names = vim.list_extend({}, names)
                if #names == 0 then
                    vim.list_extend(names, lint.linters_by_ft["_"] or {})
                end
                vim.list_extend(names, lint.linters_by_ft["*"] or {})
                local ctx = { filename = vim.api.nvim_buf_get_name(0) }
                ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
                names = vim.tbl_filter(function(name)
                    local linter = lint.linters[name]
                    if not linter then
                        LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
                    end
                    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
                end, names)
                if #names > 0 then
                    lint.try_lint(names)
                end
            end
            vim.api.nvim_create_autocmd(opts.events, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = M.debounce(100, M.lint),
            })
        end,
    },
}
