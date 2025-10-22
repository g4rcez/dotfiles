return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters = { injected = { options = { ignore_errors = true } } },
            formatters_by_ft = {
                sh = { "shfmt" },
                lua = { "stylua" },
                ["_"] = { "trim_whitespace" },
                go = { "goimports", "gofmt" },
                python = { "isort", "black" },
                ["*"] = { "codespell", "trim_whitespace" },
                rust = { "rustfmt", lsp_format = "fallback" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
        },
    },
    {
        enabled = false,
        "nvimtools/none-ls.nvim",
        opts = function(_, opts)
            local null_ls = require "null-ls"
            local action = null_ls.builtins.code_actions
            local completion = null_ls.builtins.completion
            local format = null_ls.builtins.formatting
            local hover = null_ls.builtins.hover
            local diagnostics = null_ls.builtins.diagnostics
            null_ls.setup {
                border = "rounded",
                log_level = "info",
                diagnostics_format = "#{c} #{m} (#{s})",
                sources = {
                    format.stylua,
                    hover.printenv,
                    completion.tags,
                    action.gitrebase,
                    action.proselint,
                    completion.spell,
                    format.prettierd,
                    format.rustywind,
                    hover.dictionary,
                    diagnostics.hadolint,
                    diagnostics.yamllint,
                    diagnostics.stylelint,
                    -- diagnostics.trail_space,
                    diagnostics.dotenv_linter,
                    diagnostics.editorconfig_checker,
                    null_ls.builtins.code_actions.refactoring,
                    -- null_ls.builtins.formatting.codespell.with {
                    --     extra_args = { "--builtin", "clear,rare,en-GB_to_en-US", "--locale", "en,pt-BR" },
                    -- },
                },
            }
            return opts
        end,
    },
}
