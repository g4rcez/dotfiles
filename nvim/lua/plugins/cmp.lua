local function border(hl_name)
    return {
        { '╭', hl_name },
        { '─', hl_name },
        { '╮', hl_name },
        { '│', hl_name },
        { '╯', hl_name },
        { '─', hl_name },
        { '╰', hl_name },
        { '│', hl_name },
    }
end

return {
    {
        'roobert/tailwindcss-colorizer-cmp.nvim',
        config = function()
            require('tailwindcss-colorizer-cmp').setup {
                color_square_width = 4,
            }
        end,
    },
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'f3fora/cmp-spell',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-calc',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-emoji',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-path',
            'onsails/lspkind.nvim',
            'saadparwaiz1/cmp_luasnip',
            { 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
        },
        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            local lspkind = require 'lspkind'
            luasnip.config.setup {}
            cmp.config.formatting = { format = require('tailwindcss-colorizer-cmp').formatter }
            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = 'menu,menuone,noinsert' },
                window = {
                    completion = cmp.config.window.bordered {
                        col_offset = -3,
                        side_padding = 0,
                        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
                    },
                    documentation = {
                        border = border 'CmpDocBorder',
                        winhighlight = 'Normal:CmpDoc',
                    },
                },
                formatting = {
                    fields = { 'kind', 'abbr', 'menu' },
                    format = function(entry, vim_item)
                        local kind = lspkind.cmp_format {
                            mode = 'symbol_text',
                            maxwidth = 50,
                        }(entry, vim_item)
                        local strings = vim.split(kind.kind, '%s', { trimempty = true })
                        kind.kind = ' ' .. strings[1] .. ' '
                        kind.menu = '    (' .. strings[2] .. ')'
                        return kind
                    end,
                },
                -- For an understanding of why these mappings were
                -- chosen, you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lua' },
                    { name = 'path' },
                    { name = 'buffer' },
                    { name = 'calc' },
                    { name = 'cody' },
                    { name = 'emoji' },
                    { name = 'luasnip' },
                    { name = 'lazydev', group_index = 0 },
                    { name = 'spell', keyword_length = 4 },
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-a>'] = cmp.mapping.confirm { select = true },
                    ['<Enter>'] = cmp.mapping.confirm { select = true },
                    ['<Tab>'] = cmp.mapping.confirm { select = true },
                    ['<C-Space>'] = cmp.mapping.complete {},
                    ['<C-l>'] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { 'i', 's' }),
                    ['<C-h>'] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { 'i', 's' }),
                },
            }
        end,
    },
}
