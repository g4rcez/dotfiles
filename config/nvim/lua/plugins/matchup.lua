return {
    cond = not require("config.vscode").isVscode(),
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    ---@type matchup.Config
    opts = {
        treesitter = {
            stopline = 500,
        },
    },
}
