return {
    {
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
                    format.prettier,
                    action.gitrebase,
                    action.proselint,
                    completion.spell,
                    format.pg_format,
                    format.prettierd,
                    format.rustywind,
                    hover.dictionary,
                    diagnostics.hadolint,
                    diagnostics.yamllint,
                    diagnostics.stylelint,
                    diagnostics.trail_space,
                    diagnostics.dotenv_linter,
                    diagnostics.editorconfig_checker,
                    null_ls.builtins.formatting.codespell.with {
                        extra_args = { "--builtin", "clear,rare,en-GB_to_en-US", "--locale", "en,pt-BR" },
                    },
                },
            }
            return opts
        end,
    },
}
