return {
    {
        lazy = false,
        'cjodo/convert.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
        },
        keys = {
            { '<leader>tt', '<cmd>ConvertFindCurrent<CR>', desc = 'Find next convertable unit' },
        },
    },
}
