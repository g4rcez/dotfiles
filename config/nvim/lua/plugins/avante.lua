return {
    enabled = false,
    "yetone/avante.nvim",
    cond = not require("config.vscode").isVscode(),
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
        "folke/snacks.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "HakonHarnes/img-clip.nvim",
        "nvim-tree/nvim-web-devicons",
        "yousefhadder/markdown-plus.nvim",
    },
    opts = {
        provider = "pi",
        acp_providers = {
            pi = { command = "pi-acp", args = {} },
        },
        input = { provider = "snacks" },
        selector = { provider = "snacks" },
        file_selector = { provider = "snacks" },
    },
}
