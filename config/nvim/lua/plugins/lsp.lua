return {
    "kabouzeid/nvim-lspinstall",
    { "dnlhc/glance.nvim", cmd = "Glance" },
    {
        "nvimdev/lspsaga.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = { ui = { enable = false, code_action = "" } },
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
                { path = "lazy.nvim",          words = { "Lazy" } },
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
