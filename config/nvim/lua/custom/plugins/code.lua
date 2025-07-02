local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "mattn/emmet-vim",
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",
    "JoosepAlviste/nvim-ts-context-commentstring",
    { "smjonas/inc-rename.nvim", opts = {} },
    { "numToStr/Comment.nvim", opts = {} },
    {
        "stevearc/quicker.nvim",
        event = "FileType qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {},
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
        keys = {
            { "<leader>cJ", "<cmd>TSJToggle<cr>", desc = "[J]oin Toggle" },
            { "<leader>cj", "<cmd>TSJToggle<cr>", desc = "[j]oin Toggle" },
        },
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
            enable_hex = true,
            enable_hsl = true,
            enable_rgb = true,
            exclude_buftypes = {},
            render = "background",
            enable_tailwind = true,
            exclude_filetypes = {},
            virtual_symbol = "■",
            enable_short_hex = true,
            enable_var_usage = true,
            enable_named_colors = true,
            virtual_symbol_prefix = "",
            virtual_symbol_suffix = " ",
            virtual_symbol_position = "inline",
        },
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        opts = {
            filetypes = { "*" },
            buftypes = {},
            user_commands = true,
            lazy_load = false,
            user_default_options = {
                names = true,
                names_opts = { lowercase = true, camelcase = true, uppercase = true, strip_digits = false },
                names_custom = false,
                RGB = true,
                RGBA = true,
                RRGGBB = true,
                RRGGBBAA = true,
                AARRGGBB = true,
                rgb_fn = true,
                hsl_fn = true,
                css = true,
                css_fn = true,
                tailwind = "both",
                tailwind_opts = { update_names = "both" },
                sass = { enable = true, parsers = { "css" } },
                mode = "virtualtext",
                virtualtext = "■",
                virtualtext_inline = "before",
                virtualtext_mode = "foreground",
                always_update = true,
                hooks = { do_lines_parse = false },
            },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        opts = { opts = { enable_close = true, enable_rename = true, enable_close_on_slash = true } },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = {},
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            events = { "BufWritePost", "BufReadPost", "InsertLeave" },
            linters = {},
            linters_by_ft = {
                javascript = { "eslint" },
                typescript = { "eslint" },
                javascriptreact = { "eslint" },
                typescriptreact = { "eslint" },
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
