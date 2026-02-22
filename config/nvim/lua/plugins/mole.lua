return {
    "zion-off/mole.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
        keys = {
            annotate = "<leader>ma", -- visual mode
            start_session = "<leader>ms", -- normal mode
            stop_session = "<leader>mq", -- normal mode
            toggle_window = "<leader>mw", -- normal mode
        },
    },
}
