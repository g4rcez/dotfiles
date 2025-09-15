return {
    "kabouzeid/nvim-lspinstall",
    {
        "nvimdev/lspsaga.nvim",
        enable = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            breadcrumbs = { enable = false },
            winbar = { enable = false },
            symbol_in_winbar = { enable = false },
            ui = { enable = false, code_action = "" },
            hover = {
                max_width = 0.9,
                max_height = 0.9,
                open_link = "gx",
                open_browser = "!chrome",
            },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "lazy.nvim", words = { "Lazy" } },
            },
        },
    },
}
