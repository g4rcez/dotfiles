return {
    {
        "Pocco81/auto-save.nvim",
        config = function()
            require("auto-save").setup({
                enabled = true,
                debounce_delay = 2000,
                trigger_events = { "InsertLeave", "TextChanged" },
            })
        end,
    },
}
