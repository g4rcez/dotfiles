return {
    {
        "Pocco81/auto-save.nvim",
        config = function()
            require("auto-save").setup({ enabled = false, debounce_delay = 135 })
        end,
    },
}
