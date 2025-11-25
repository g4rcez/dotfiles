local fileTypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
    "tpope/vim-sensible",
    "tpope/vim-surround",
    "editorconfig/editorconfig-vim",
    { "nmac427/guess-indent.nvim", opts = { auto_cmd = true, override_editorconfig = false } },
    { enabled = false, "windwp/nvim-ts-autotag" },
    { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
    { "tronikelis/ts-autotag.nvim", opts = { auto_close = { enabled = true }, auto_rename = { enabled = true } } },
    { "zeioth/garbage-day.nvim", dependencies = "neovim/nvim-lspconfig", event = "VeryLazy", opts = {} },
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true, opts = { check_ts = true } },
    { opts = {}, "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },
    {
        "olrtg/nvim-emmet",
        config = function()
            vim.keymap.set({ "n", "v" }, "<leader>ce", function()
                require("nvim-emmet").wrap_with_abbreviation()
            end, { desc = "[e]mmet" })
        end,
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
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        opts = {
            preset = "minimal",
            transparent_bg = false,
            transparent_cursorline = true,
            options = {
                multilines = { enabled = true },
            },
        },
    },
    {
        "rachartier/tiny-code-action.nvim",
        dependencies = { { "nvim-lua/plenary.nvim" }, { "folke/snacks.nvim" } },
        event = "LspAttach",
        opts = {
            backend = "delta",
            picker = "snacks",
            resolve_timeout = 100,
            backend_opts = {
                diffsofancy = { header_lines_to_remove = 4 },
                delta = { header_lines_to_remove = 4, args = { "--line-numbers" } },
                difftastic = {
                    header_lines_to_remove = 1,
                    args = {
                        "--color=always",
                        "--display=inline",
                        "--syntax-highlight=on",
                    },
                },
            },
            signs = {
                quickfix = { "", { link = "DiagnosticWarning" } },
                others = { "", { link = "DiagnosticWarning" } },
                refactor = { "", { link = "DiagnosticInfo" } },
                ["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
                ["refactor.extract"] = { "", { link = "DiagnosticError" } },
                ["source.organizeImports"] = { "", { link = "DiagnosticWarning" } },
                ["source.fixAll"] = { "󰃢", { link = "DiagnosticError" } },
                ["source"] = { "", { link = "DiagnosticError" } },
                ["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
                ["codeAction"] = { "", { link = "DiagnosticWarning" } },
            },
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
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            diagnostics = { virtual_text = false },
            inlay_hints = { enabled = false },
            servers = {
                ["cspell-lsp"] = {},
                dockerls = {},
                docker_compose_language_service = {},
                vstls = {
                    settings = {
                        typescript = {
                            tsserver = { maxTsServerMemory = 12000 },
                            suggest = { enabled = true, completeFunctionCalls = true },
                            inlayHints = {
                                variableTypes = { enabled = true },
                                parameterTypes = { enabled = true },
                                enumMemberValues = { enabled = true },
                                parameterNames = { enabled = "literals" },
                                functionLikeReturnTypes = { enabled = true },
                                propertyDeclarationTypes = { enabled = true },
                            },
                        },
                    },
                },
            },
        },
    },
}
