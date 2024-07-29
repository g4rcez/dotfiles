return {
    { 'tpope/vim-fugitive', event = 'VeryLazy' },
    { 'sindrets/diffview.nvim', event = 'VeryLazy', cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' } },
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
                on_attach = function(bufnr)
                    bufnr = nil
                end,
            },
        },
    },
}
