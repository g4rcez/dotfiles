return {
    {
        'johmsalas/text-case.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        config = function()
            require('textcase').setup {}
            require('telescope').load_extension 'textcase'
        end,
        keys = {
            'ga',
            { '<leader>tt', '<cmd>TextCaseOpenTelescope<CR>', mode = { 'n', 'x' }, desc = 'Telescope' },
        },
        cmd = {
            'Subs',
            'TextCaseOpenTelescope',
            'TextCaseOpenTelescopeQuickChange',
            'TextCaseOpenTelescopeLSPChange',
            'TextCaseStartReplacingCommand',
        },
    },
}
