return {
    {
        "smjonas/inc-rename.nvim",
        lazy = false,
        priority = 100,
        enabled = true,
        config = function()
            require("inc_rename").setup({ preview_empty_name = true, show_message = true })
        end,
    },
}
