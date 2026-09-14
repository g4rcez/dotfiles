local javascript_tools = require "config.javascript_tools"

local function is_oxc(bufnr)
    if javascript_tools.oxlint_root(bufnr) then
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
                oxfmt = { append_args = { "--trailing-comma", "none" } },
                prettier = { append_args = { "--trailing-comma", "none" } },
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
                ["prompt-pi"] = { "prettier" },
                ["pi-prompt"] = { "prettier" },
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
