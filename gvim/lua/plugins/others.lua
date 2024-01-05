return {
    "LukasPietzschmann/telescope-tabs",
    "folke/twilight.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "rest-nvim/rest.nvim",
    { "pwntester/octo.nvim", opts = {}, cmd = "Octo" },
    {
        "roobert/tailwindcss-colorizer-cmp.nvim",
        config = function()
            require("tailwindcss-colorizer-cmp").setup({
                color_square_width = 2,
            })
        end,
    },
}
