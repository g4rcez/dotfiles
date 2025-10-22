return {
    {
        "mistweaverco/kulala.nvim",
        ft = { "http", "rest" },
        keys = {
            { "<leader>Rs", desc = "Send request" },
            { "<leader>Ra", desc = "Send all requests" },
            { "<leader>Rb", desc = "Open scratchpad" },
        },
        opts = {
            global_keymaps = true,
            kulala_keymaps_prefix = "",
            global_keymaps_prefix = "<leader>R",
        },
    },
}
