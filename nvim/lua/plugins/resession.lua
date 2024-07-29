return {
    {
        'rmagatti/auto-session',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        opts = {
            auto_restore_enabled = false,
            auto_save_enabled = true,
            auto_session_enable_last_session = true,
            bypass_session_save_file_types = { 'alpha' },
            auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
            auto_session_create_enabled = function()
                local cmd = 'git rev-parse --is-inside-work-tree'
                return vim.fn.system(cmd) == 'true\n'
            end,
        },
    },
}
