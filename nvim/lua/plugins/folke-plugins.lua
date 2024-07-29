return {
    { 'folke/neoconf.nvim' },
    { 'folke/twilight.nvim', opts = {} },
    {
        'folke/persistence.nvim',
        event = 'BufReadPre',
        opts = {
            pre_save = function()
                vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' })
            end,
        },
    },
    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        opts = { char = { keys = { 'f', 'F', 't', 'T' } } },
        keys = {
            {
                's',
                mode = { 'n', 'x', 'o' },
                function()
                    require('flash').jump()
                end,
                desc = 'Flash',
            },
        },
    },
    {
        'MeanderingProgrammer/markdown.nvim',
        main = 'render-markdown',
        opts = {},
        name = 'render-markdown',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    },
    { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = true } },
    {
        'folke/zen-mode.nvim',
        opts = {
            plugins = {
                wezterm = { enabled = true, font = '+2' },
            },
        },
    },
}
