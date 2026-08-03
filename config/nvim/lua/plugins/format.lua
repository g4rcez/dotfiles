local oxc_markers = { "oxlint.json", ".oxlintrc.json", "oxlint.config.js", "oxlint.config.ts", "oxlint.config.mjs", "oxlint.config.cjs" }

local function has_oxc(bufnr)
    return vim.fs.root(bufnr, oxc_markers) ~= nil
end

local function is_oxc(bufnr)
    if has_oxc(bufnr) then
        return { "oxfmt" }
    end
    return { "prettier" }
end

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
            require("conform").format { lsp_fallback = true }
        end,
        mode = { "n", "v" },
        desc = "[c]ode [F]ormat",
    },
}

return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre", "BufNewFile" },
        cmd = { "ConformInfo" },
        keys = keys,
        opts = {
            format_on_save = false,
            notify_on_error = false,
            formatters = {
                oxfmt = { trailingComma = "none" },
                prettier = { trailingComma = "none" },
                prettierd = { trailingComma = "none" },
                shfmt = { append_args = { "-i", "4" } },
            },
            formatters_by_ft = {
                json = is_oxc,
                sh = { "shfmt" },
                zsh = { "shfmt" },
                bash = { "shfmt" },
                lua = { "stylua" },
                javascript = is_oxc,
                typescript = is_oxc,
                css = { "prettier" },
                html = { "prettier" },
                yaml = { "prettier" },
                liquid = { "prettier" },
                svelte = { "prettier" },
                graphql = { "prettier" },
                javascriptreact = is_oxc,
                typescriptreact = is_oxc,
                markdown = { "prettier" },
                python = { "isort", "black" },
            },
        },
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            linters_by_ft = {
                css = { "stylelint" },
                yaml = { "yamllint" },
                scss = { "stylelint" },
                dockerfile = { "hadolint" },
            },
        },
        config = function(_, opts)
            local lint = require "lint"
            lint.linters_by_ft = opts.linters_by_ft
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
