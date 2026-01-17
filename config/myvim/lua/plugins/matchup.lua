return {
    cond = not require("config.vscode").isVscode(),
    "andymass/vim-matchup",
    ---@type matchup.Config
    opts = {
        treesitter = {
            stopline = 500,
        },
    },
}
