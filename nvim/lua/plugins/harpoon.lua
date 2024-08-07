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
    {
        'LintaoAmons/bookmarks.nvim',
        dependencies = {
            { 'nvim-telescope/telescope.nvim' },
            { 'stevearc/dressing.nvim' },
        },
        opts = {
            json_db_path = vim.fs.normalize(vim.fn.stdpath 'config' .. '/bookmarks.db.json'),
        },
    },
}
