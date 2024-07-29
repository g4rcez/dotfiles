return {
    {
        'romgrk/barbar.nvim',
        dependencies = { 'lewis6991/gitsigns.nvim', 'nvim-tree/nvim-web-devicons' },
        init = function()
            vim.g.barbar_auto_setup = true
        end,
        opts = {
            animation = false,
            highlight_alternate = true,
            maximum_padding = 2,
            minimum_padding = 2,
            maximum_length = 32,
            semantic_letters = true,
            icons = {
                preset = 'slanted',
                buffer_index = true,
                buffer_number = false,
                filetype = { custom_colors = false, enabled = true },
                separator_at_end = true,
            },
        },
    },
}
