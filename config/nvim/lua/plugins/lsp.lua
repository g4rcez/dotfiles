return {
    "kabouzeid/nvim-lspinstall",
    { "dnlhc/glance.nvim", cmd = "Glance" },
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
        "oribarilan/lensline.nvim",
        enabled = false,
        tag = "1.0.0",
        event = "LspAttach",
        config = function()
            require("lensline").setup()
        end,
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
    {
        opts = {},
        "vuki656/package-info.nvim",
        event = "BufRead package.json",
        dependencies = { "MunifTanjim/nui.nvim" },
    },
}
