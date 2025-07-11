return {
    {
        "nvimtools/none-ls.nvim",
        opts = function(_, opts)
            local null_ls = require "null-ls"
            null_ls.setup {
                sources = {
                    null_ls.builtins.code_actions.gitrebase,
                    null_ls.builtins.completion.spell,
                    -- null_ls.builtins.diagnostics.actionlint,
                    null_ls.builtins.diagnostics.codespell,
                    null_ls.builtins.diagnostics.dotenv_linter,
                    null_ls.builtins.diagnostics.editorconfig_checker,
                    null_ls.builtins.diagnostics.hadolint,
                    -- null_ls.builtins.diagnostics.semgrep,
                    null_ls.builtins.diagnostics.stylelint,
                    null_ls.builtins.diagnostics.yamllint,
                    null_ls.builtins.formatting.codespell,
                    null_ls.builtins.formatting.pg_format,
                    null_ls.builtins.formatting.prettier,
                    null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.formatting.rustywind,
                    null_ls.builtins.formatting.stylua,
                },
            }
            return opts
        end,
    },
}
