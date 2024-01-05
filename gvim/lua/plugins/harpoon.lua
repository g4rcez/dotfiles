return {
    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function()
            require("harpoon").setup({
                global_settings = {
                    save_on_change = true,
                    mark_branch = false,
                    tabline = true,
                    tabline_prefix = "   ",
                    tabline_suffix = "   ",
                },
            })
        end,
    },
}
