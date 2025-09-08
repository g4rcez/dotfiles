local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",
    { "smjonas/inc-rename.nvim", opts = {} },
    { "dmmulroy/ts-error-translator.nvim" },
    { opts = {}, "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },
    { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
    {
        "olrtg/nvim-emmet",
        config = function()
            vim.keymap.set(
                { "n", "v" },
                "<leader>ce",
                require("nvim-emmet").wrap_with_abbreviation,
                { desc = "[e]mmet" }
            )
        end,
    },
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
        opts = { use_default_keymaps = false, max_join_length = 1000 },
        keys = {
            { "<leader>cJ", "<cmd>TSJToggle<cr>", desc = "[J]oin Toggle" },
            { "<leader>cj", "<cmd>TSJToggle<cr>", desc = "[j]oin Toggle" },
        },
    },
    { "nmac427/guess-indent.nvim", opts = { auto_cmd = true, override_editorconfig = false } },
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
        "windwp/nvim-ts-autotag",
        config = true,
        opts = {
            opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = true,
            },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        opts = { check_ts = true },
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        opts = {
            -- Style preset for diagnostic messages
            -- Available options:
            -- "modern", "classic", "minimal", "powerline",
            -- "ghost", "simple", "nonerdfont", "amongus"
            preset = "minimal",
            transparent_bg = false, -- Set the background of the diagnostic to transparent
            transparent_cursorline = false, -- Set the background of the cursorline to transparent (only one the first diagnostic)
            hi = {
                error = "DiagnosticError", -- Highlight group for error messages
                warn = "DiagnosticWarn", -- Highlight group for warning messages
                info = "DiagnosticInfo", -- Highlight group for informational messages
                hint = "DiagnosticHint", -- Highlight group for hint or suggestion messages
                arrow = "NonText", -- Highlight group for diagnostic arrows
                background = "CursorLine",
                mixing_color = "None",
            },
            options = {
                -- Display the source of the diagnostic (e.g., basedpyright, vsserver, lua_ls etc.)
                show_source = { enabled = true, if_many = true },
                use_icons_from_diagnostic = false,
                set_arrow_to_diag_color = true,
                add_messages = true,
                throttle = 200,
                softwrap = 30,
                multilines = { enabled = true, always_show = false, trim_whitespaces = false, tabstop = 4 },
                show_all_diags_on_cursorline = false,
                -- Enable diagnostics in Insert mode
                -- If enabled, it is better to set the `throttle` option to 0 to avoid visual artifacts
                enable_on_insert = false,
                -- Enable diagnostics in Select mode (e.g when auto inserting with Blink)
                enable_on_select = false,
                overflow = { mode = "wrap", padding = 0 },
                -- Configuration for breaking long messages into separate lines
                break_line = { enabled = true, after = 30 },
                format = nil,
                virt_texts = { priority = 2048 },
                severity = {
                    vim.diagnostic.severity.ERROR,
                    vim.diagnostic.severity.WARN,
                    vim.diagnostic.severity.INFO,
                    vim.diagnostic.severity.HINT,
                },
                overwrite_events = nil,
            },
            disabled_ft = {},
        },
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
