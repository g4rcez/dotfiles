local M = {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
}

function M.config()
    require('oil').setup {
        delete_to_trash = true,
        default_file_explorer = true,
        columns = { 'icon', 'size', 'mtime' },
        view_options = {
            show_hidden = true,
            case_insensitive = true,
        },
        use_default_keymaps = false,
        keymaps = {
            ['-'] = 'actions.parent',
            ['<C-c>'] = 'actions.close',
            ['<C-h>'] = { 'actions.select', opts = { horizontal = true }, desc = 'Open the entry in a horizontal split' },
            ['<C-l>'] = 'actions.refresh',
            ['<C-p>'] = 'actions.preview',
            ['<C-t>'] = { 'actions.select', opts = { tab = true }, desc = 'Open the entry in new tab' },
            ['<CR>'] = 'actions.select',
            ['_'] = 'actions.open_cwd',
            ['`'] = 'actions.cd',
            ['g.'] = 'actions.toggle_hidden',
            ['g?'] = 'actions.show_help',
            ['g\\'] = 'actions.toggle_trash',
            ['gs'] = 'actions.change_sort',
            ['gx'] = 'actions.open_external',
            ['q'] = 'actions.close',
            ['~'] = { 'actions.cd', opts = { scope = 'tab' }, desc = ':tcd to the current oil directory' },
        },
        float = {
            padding = 4,
            max_width = 0,
            max_height = 0,
            border = 'rounded',
            win_options = { winblend = 0 },
            preview_split = 'auto',
            override = function(conf)
                return conf
            end,
        },
    }
end

return M
