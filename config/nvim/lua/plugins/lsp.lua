return {
    "kabouzeid/nvim-lspinstall",
    { "dnlhc/glance.nvim",              cmd = "Glance" },
    {
        "nvimdev/lspsaga.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = { ui = { enable = false, code_action = "", } },
    },
    { "bezhermoso/tree-sitter-ghostty", build = "make nvim_install" },
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
