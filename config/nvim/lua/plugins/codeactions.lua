return {
    {
        cond = not require("config.vscode").isVscode(),
        "rachartier/tiny-code-action.nvim",
        dependencies = { { "nvim-lua/plenary.nvim" }, { "folke/snacks.nvim" } },
        keys = {
            {
                "<leader>ca",
                function()
                    require("tiny-code-action").code_action()
                end,
                mode = { "n", "x" },
                desc = "[c]ode [a]ctions",
            },
        },
        event = "LspAttach",
        opts = {
            backend = "delta",
            picker = "snacks",
            resolve_timeout = 100,
            backend_opts = { delta = { header_lines_to_remove = 4, args = { "--line-numbers" } } },
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
}
