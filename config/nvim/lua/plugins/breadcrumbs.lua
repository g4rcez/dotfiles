local vscode = require "config.vscode"

return {
    {
        "Bekaboo/dropbar.nvim",
        cond = not vscode.isVscode(),
        event = "UIEnter",
        opts = {
            icons = {
                ui = {
                    bar = {
                        separator = "› ",
                    },
                },
            },
            bar = {
                enable = false,
                hover = false,
                padding = { left = 0, right = 0 },
            },
        },
        config = function(_, opts)
            require("dropbar").setup(opts)

            local dropbar_api = require "dropbar.api"
            vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick breadcrumbs" })
            vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
            vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
        end,
    },
}
