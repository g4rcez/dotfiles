return {
    {
        ft = { "http", "rest" },
        "mistweaverco/kulala.nvim",
        cond = not require("config.vscode").isVscode(),
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" },
            { "<leader>Rb", desc = "Open scratchpad" },
        },
        opts = {
            global_keymaps = false,
            kulala_keymaps_prefix = "",
            global_keymaps_prefix = "<leader>R",
        },
    },
}
