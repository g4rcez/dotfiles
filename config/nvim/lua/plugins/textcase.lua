return {
    "johmsalas/text-case.nvim",
    lazy = false,
    keys = { "ga", mode = "v", desc = "Change case" },
    config = function()
        require("textcase").setup({})
    end,
    cmd = {
        "Subs",
        "TextCaseOpenTelescope",
        "TextCaseOpenTelescopeQuickChange",
        "TextCaseOpenTelescopeLSPChange",
        "TextCaseStartReplacingCommand",
    },
}
