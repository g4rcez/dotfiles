return {
    {
        "Pocco81/auto-save.nvim",
        config = function()
            require("auto-save").setup({
                enabled = false,
                debounce_delay = 2000,
                trigger_events = { "InsertLeave", "TextChanged" },
            })
        end,
    },
}
