return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        workspaces = {
            {
                name = "knowledge",
                path = "~/Documents/g4rcez/knowledge",
            },
        },
    },
}
