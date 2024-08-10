return {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
        { '\\', '<cmd>Neotree reveal<CR>', desc = 'NeoTree reveal' },
        {
            '<leader>eg',
            function()
                require('neo-tree.command').execute { source = 'git_status', toggle = true }
            end,
            desc = 'Git Explorer',
        },
    },
    init = function()
        -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
        -- because `cwd` is not set up properly.
        vim.api.nvim_create_autocmd('BufEnter', {
            group = vim.api.nvim_create_augroup('Neotree_start_directory', { clear = true }),
            desc = 'Start Neo-tree with directory',
            once = true,
            callback = function()
                if package.loaded['neo-tree'] then
                    return
                else
                    local stats = vim.uv.fs_stat(vim.fn.argv(0))
                    if stats and stats.type == 'directory' then
                        require 'neo-tree'
                    end
                end
            end,
        })
    end,
    opts = {
        popup_border_style = 'rounded',
        enable_git_status = true,
        enable_diagnostics = true,
        window = {
            position = 'right',
        },
        filesystem = {
            window = {
                mappings = {
                    ['\\'] = 'close_window',
                },
            },
        },
    },
}
