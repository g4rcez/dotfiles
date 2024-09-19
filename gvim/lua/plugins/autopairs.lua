return {
    { 'windwp/nvim-ts-autotag', opts = {} },
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        dependencies = { 'hrsh7th/nvim-cmp' },
        opts = {
            check_ts = true,
            ts_config = { java = false },
            fast_wrap = {
                map = '<M-e>',
                chars = { '{', '[', '(', '"', "'" },
                pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub('%s+', ''),
                offset = 0,
                end_key = '$',
                keys = 'qwertyuiopzxcvbnmasdfghjkl',
                check_comma = true,
                highlight = 'PmenuSel',
                highlight_grey = 'LineNr',
            }
        },
        config = function()
            require('nvim-autopairs').setup {}
            local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
            local cmp = require 'cmp'
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end,
    },
}
