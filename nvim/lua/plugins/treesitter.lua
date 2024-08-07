return {
    {
        'mistweaverco/kulala.nvim',
        ft = 'http',
        opts = {},
        keys = {
            { '<leader>R', '', desc = '+Rest' },
            { '<leader>Rs', "<cmd>lua require('kulala').run()<cr>", desc = 'Send the request' },
            { '<leader>Rt', "<cmd>lua require('kulala').toggle_view()<cr>", desc = 'Toggle headers/body' },
            { '<leader>Rp', "<cmd>lua require('kulala').jump_prev()<cr>", desc = 'Jump to previous request' },
            { '<leader>Rn', "<cmd>lua require('kulala').jump_next()<cr>", desc = 'Jump to next request' },
        },
    },
    { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = {
                'bash',
                'c',
                'diff',
                'http',
                'html',
                'lua',
                'luadoc',
                'markdown',
                'markdown_inline',
                'javascript',
                'query',
                'vim',
                'vimdoc',
                'typescript',
            },
            -- Autoinstall languages that are not installed
            auto_install = true,
            highlight = {
                enable = true,
                use_languagetree = true,
                additional_vim_regex_highlighting = { 'ruby', 'javascript' },
            },
            indent = { enable = true, disable = { 'ruby' } },
        },
        config = function(_, opts)
            require('nvim-treesitter.install').prefer_git = true
            require('nvim-treesitter.configs').setup(opts)
        end,
    },
}
