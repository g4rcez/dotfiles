return {
    {
        cond = not require("config.vscode").isVscode(),
        "folke/persistence.nvim",
        event = "VimEnter",
        keys = {
            {
                "<leader>ww",
                function()
                    require("persistence").load()
                end,
                desc = "Restore workspace session",
            },
            {
                "<leader>wl",
                function()
                    require("persistence").load { last = true }
                end,
                desc = "Restore last session",
            },
            {
                "<leader>ws",
                function()
                    require("persistence").select()
                end,
                desc = "Select workspace session",
            },
            {
                "<leader>wS",
                function()
                    require("persistence").save()
                end,
                desc = "Save workspace session",
            },
            {
                "<leader>wd",
                function()
                    require("persistence").stop()
                end,
                desc = "Stop workspace session",
            },
        },
        opts = {
            branch = true,
            need = 1,
        },
        config = function(_, opts)
            local persistence = require "persistence"
            persistence.setup(opts)
            vim.api.nvim_create_autocmd("VimEnter", {
                group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
                callback = function()
                    if vim.fn.argc() == 0 and vim.fn.getcwd() ~= vim.env.HOME then
                        vim.schedule(function() persistence.load() end)
                    end
                end,
            })
        end,
    },
}
