local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "mattn/emmet-vim",
    "tpope/vim-sleuth",
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",

    { "numToStr/Comment.nvim",                       opts = {} },
    "JoosepAlviste/nvim-ts-context-commentstring",
    { "Bekaboo/dropbar.nvim",                        dependencies = { "nvim-telescope/telescope-fzf-native.nvim" } },
    { "nvim-treesitter/nvim-treesitter-textobjects", dependencies = { "nvim-treesitter/nvim-treesitter" } },
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
        ft = fileTypes,
        event = "InsertEnter",
        "axelvc/template-string.nvim",
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
        "smoka7/multicursors.nvim",
        event = "VeryLazy",
        opts = {},
        dependencies = { "nvimtools/hydra.nvim" },
        cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
        keys = {
            {
                mode = { "v", "n" },
                "<C-n>",
                "<cmd>MCstart<cr>",
                desc = "Multicursor",
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
            enable_tailwind = false,
            exclude_filetypes = {},
            exclude_buftypes = {},
        },
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        opts = {
            filetypes = { "*" },          -- Filetype options.  Accepts table like `user_default_options`
            buftypes = {},                -- Buftype options.  Accepts table like `user_default_options`
            user_commands = true,         -- Enable all or some usercommands
            lazy_load = false,            -- Lazily schedule buffer highlighting setup function
            user_default_options = {
                names = true,             -- "Name" codes like Blue or red.  Added from `vim.api.nvim_get_color_map()`
                names_opts = {            -- options for mutating/filtering names.
                    lowercase = true,     -- name:lower(), highlight `blue` and `red`
                    camelcase = true,     -- name, highlight `Blue` and `Red`
                    uppercase = true,     -- name:upper(), highlight `BLUE` and `RED`
                    strip_digits = false, -- ignore names with digits,
                    -- highlight `blue` and `red`, but not `blue3` and `red4`
                },
                names_custom = false,
                RGB = true,                -- #RGB hex codes
                RGBA = true,               -- #RGBA hex codes
                RRGGBB = true,             -- #RRGGBB hex codes
                RRGGBBAA = true,           -- #RRGGBBAA hex codes
                AARRGGBB = true,           -- 0xAARRGGBB hex codes
                rgb_fn = false,            -- CSS rgb() and rgba() functions
                hsl_fn = false,            -- CSS hsl() and hsla() functions
                css = true,                -- Enable all CSS *features*:
                -- names, RGB, RGBA, RRGGBB, RRGGBBAA, AARRGGBB, rgb_fn, hsl_fn
                css_fn = true,             -- Enable all CSS *functions*: rgb_fn, hsl_fn
                -- Tailwind colors.  boolean|'normal'|'lsp'|'both'.  True sets to 'normal'
                tailwind = true,           -- Enable tailwind colors
                tailwind_opts = {          -- Options for highlighting tailwind names
                    update_names = "both", -- When using tailwind = 'both', update tailwind names from LSP results.  See tailwind section
                },
                -- parsers can contain values used in `user_default_options`
                sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
                -- Highlighting mode.  'background'|'foreground'|'virtualtext'
                mode = "background",                            -- Set the display mode
                -- Virtualtext character to use
                virtualtext = "■",
                -- Display virtualtext inline with color.  boolean|'before'|'after'.  True sets to 'after'
                virtualtext_inline = true,
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
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "gbprod/none-ls-shellcheck.nvim" },
        opts = function(_, opts)
            local nonels = require "null-ls"
            opts.sources = {
                opts.sources,
                nonels.builtins.formatting.stylua,
                nonels.builtins.diagnostics.eslint,
                nonels.builtins.completion.spell,
                nonels.builtins.code_actions.gitrebase,
                nonels.builtins.completion.nvim_snippets,
                nonels.builtins.diagnostics.codespell,
                nonels.builtins.diagnostics.commitlint,
                nonels.builtins.diagnostics.commitlint,
                nonels.builtins.diagnostics.semgrep,
                nonels.builtins.formatting.prettier,
                nonels.builtins.formatting.prettierd,
                nonels.builtins.formatting.rustywind,
                require "none-ls-shellcheck.diagnostics",
                require "none-ls-shellcheck.code_actions",
            }
            return opts
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-ts-autotag").setup {
                opts = {
                    -- Defaults
                    enable_close = true,          -- Auto close tags
                    enable_rename = true,         -- Auto rename pairs of tags
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
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "ruby" },
            },
            indent = { enable = true },
        },
    },
}
