return {
    {
        'romgrk/barbar.nvim',
        dependencies = { 'lewis6991/gitsigns.nvim', 'nvim-tree/nvim-web-devicons' },
        init = function()
            vim.g.barbar_auto_setup = true
        end,
        opts = {
            animation = false,
            highlight_alternate = false,
            maximum_padding = 1,
            minimum_padding = 1,
            maximum_length = 32,
            semantic_letters = true,
            icons = {
                preset = 'powerline',
                buffer_index = true,
                buffer_number = false,
                separator_at_end = true,
                filetype = { custom_colors = false, enabled = true },
            },
        },
    },
}
