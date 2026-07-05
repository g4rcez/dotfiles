return {
    "folke/sidekick.nvim",
    cond = not require("config.vscode").isVscode(),
    opts = {
        nes = { enabled = false },
        cli = {
            picker = "snacks",
            mux = {
                backend = "tmux",
                enabled = vim.env.TMUX ~= nil,
            },
            tools = {
                pi = {
                    cmd = { "pi" },
                    is_proc = "\\<pi\\>",
                    native_scroll = false,
                    resume = { "--resume" },
                    continue = { "--continue" },
                },
            },
        },
    },
    keys = {
        {
            "<c-.>",
            function()
                require("sidekick.cli").focus { name = "pi" }
            end,
            desc = "Sidekick Focus Pi",
            mode = { "n", "t", "i", "x" },
        },
        {
            "<leader>ii",
            function()
                require("sidekick.cli").toggle { name = "pi", focus = true }
            end,
            desc = "Sidekick Toggle Pi",
        },
        {
            "<leader>id",
            function()
                require("sidekick.cli").close { name = "pi" }
            end,
            desc = "Sidekick Detach Pi",
        },
        {
            "<leader>it",
            function()
                require("sidekick.cli").send { name = "pi", msg = "{this}" }
            end,
            mode = { "n", "x" },
            desc = "Sidekick Send This to Pi",
        },
        {
            "<leader>if",
            function()
                require("sidekick.cli").send { name = "pi", msg = "{file}" }
            end,
            desc = "Sidekick Send File to Pi",
        },
        {
            "<leader>iv",
            function()
                require("sidekick.cli").send { name = "pi", msg = "{selection}" }
            end,
            mode = "x",
            desc = "Sidekick Send Selection to Pi",
        },
        {
            "<leader>ip",
            function()
                require("sidekick.cli").prompt {
                    cb = function(_, text)
                        if text then
                            require("sidekick.cli").send { name = "pi", text = text }
                        end
                    end,
                }
            end,
            mode = { "n", "x" },
            desc = "Sidekick Prompt Pi",
        },
        {
            "<leader>is",
            function()
                require("sidekick.cli").select { filter = { installed = true } }
            end,
            desc = "Sidekick Select CLI",
        },
    },
}
