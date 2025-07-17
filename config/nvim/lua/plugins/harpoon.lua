return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = function(_, opts)
            opts.menu = { width = vim.api.nvim_win_get_width(0) - 4 }
            opts.settings = { save_on_toggle = true }
            return opts
        end
    }
}
