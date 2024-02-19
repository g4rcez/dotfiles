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
}
