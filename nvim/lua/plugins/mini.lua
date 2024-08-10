return {
    'echasnovski/mini.nvim',
    config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup { n_lines = 500 }
        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()
        require('mini.pairs').setup()
        require('mini.comment').setup()

        require('mini.indentscope').setup {
            draw = {
                symbol = '|',
                options = {
                    border = 'both',
                    indent_at_cursor = true,
                    try_as_border = false,
                },
            },
        }

        local hipatterns = require 'mini.hipatterns'
        hipatterns.setup {
            highlighters = {
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        }
    end,
}
