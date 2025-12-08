return {
    {
        cond = not require("config.vscode").isVscode(),
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        event = "BufEnter",
        config = true,
        keys = {
            {
                "gP",
                function()
                    require("goto-preview").goto_preview_definition()
                end,
                mode = "n",
                desc = "Goto preview",
            },
        },
    },
}
