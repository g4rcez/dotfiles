return {
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('harpoon'):setup()
        end,
    },
    {
        'letieu/harpoon-lualine',
        dependencies = {
            {
                'ThePrimeagen/harpoon',
                branch = 'harpoon2',
            },
        },
    },
}
