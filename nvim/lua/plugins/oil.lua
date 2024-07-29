local M = {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
}

function M.config()
    require('oil').setup {
        float = {},
        delete_to_trash = true,
        columns = { 'icon', 'size', 'mtime' },
        view_options = {
            show_hidden = true,
            case_insensitive = true,
        },
    }
end

return M
