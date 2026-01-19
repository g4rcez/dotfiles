local keys = {
    {
        "<leader>cr",
        function()
            vim.lsp.buf.rename()
        end,
        mode = "n",
        desc = "[c]ode [r]ename",
    },
    {
        "<leader>cf",
        function()
            vim.lsp.buf.format()
        end,
        mode = "n",
        desc = "[c]ode [F]ormat",
    },
}

return {
    {
        "nvimtools/none-ls.nvim",
        keys = keys,
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
                    format.rustywind,
                    hover.dictionary,
                    diagnostics.hadolint,
                    diagnostics.yamllint,
                    diagnostics.stylelint,
                    diagnostics.dotenv_linter,
                    -- diagnostics.trail_space,
                    null_ls.builtins.code_actions.refactoring,
                    null_ls.builtins.formatting.codespell.with {
                        extra_args = { "--builtin", "clear,rare,en-GB_to_en-US", "--locale", "en,pt-BR" },
                    },
                },
            }
            return opts
        end,
    },
    {
        enabled = false,
        "stevearc/conform.nvim",
        event = { "BufWritePre", "BufNewFile" },
        cmd = { "ConformInfo" },
        keys = keys,
        opts = {
            format_on_save = false,
            notify_on_error = false,
            formatters_by_ft = {
                css = { "prettier" },
                graphql = { "prettier" },
                html = { "prettier" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettier" },
                json = { "prettier" },
                liquid = { "prettier" },
                lua = { "stylua" },
                markdown = { "prettier" },
                python = { "isort", "black" },
                svelte = { "prettier" },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettier" },
                yaml = { "prettier" },
            },
        },
    },
}
