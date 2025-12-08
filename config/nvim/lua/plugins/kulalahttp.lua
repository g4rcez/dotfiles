return {
    cond = not require("config.vscode").isVscode(),
    {
        "mistweaverco/kulala.nvim",
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" },
            { "<leader>Rb", desc = "Open scratchpad" },
        },
        ft = { "http", "rest" },
        opts = {
            global_keymaps = false,
            kulala_keymaps_prefix = "",
            global_keymaps_prefix = "<leader>R",
        },
    },
}
