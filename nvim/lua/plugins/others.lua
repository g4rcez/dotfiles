return {
    "folke/twilight.nvim",
    "LukasPietzschmann/telescope-tabs",
    "rest-nvim/rest.nvim",
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    },
    {
        "roobert/tailwindcss-colorizer-cmp.nvim",
        config = function()
            require("tailwindcss-colorizer-cmp").setup({
                color_square_width = 4,
            })
        end,
    },
    { "nvim-pack/nvim-spectre", dependencies = { "nvim-lua/plenary.nvim" } },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
    {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
        dependencies = { "rafamadriz/friendly-snippets" },
        build = "make install_jsregexp",
    },
}
