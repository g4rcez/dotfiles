local cmp_kinds = {
    calc = '󰃬',
    Class = ' ',
    Color = '󰏘',
    Constant = ' ',
    Constructor = '',
    Enum = ' ',
    EnumMember = '',
    Event = '',
    Field = ' ',
    File = '',
    Folder = ' ',
    Function = '󰊕',
    Interface = ' ',
    Keyword = ' ',
    Method = '󰆧',
    Module = '',
    Operator = ' ',
    Property = '󰜢',
    Reference = ' ',
    Snippet = '',
    Struct = ' ',
    Text = '',
    TypeParameter = ' ',
    Unit = '',
    Value = ' ',
    Variable = ' ',
}

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
            "luckasRanarison/tailwind-tools.nvim",
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
            luasnip.config.setup {}

            -- cmp-vscode-like
            vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { bg = 'NONE', strikethrough = true, fg = '#808080' })
            vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link = 'CmpIntemAbbrMatch' })
            vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link = 'CmpItemKindVariable' })
            vim.api.nvim_set_hl(0, 'CmpItemKindText', { link = 'CmpItemKindVariable' })
            vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link = 'CmpItemKindFunction' })
            vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link = 'CmpItemKindKeyword' })
            vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link = 'CmpItemKindKeyword' })
            vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { fg = '#7E8294', bg = 'NONE', strikethrough = true })
            vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { fg = '#82AAFF', bg = 'NONE', bold = true })
            vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { fg = '#82AAFF', bg = 'NONE', bold = true })
            vim.api.nvim_set_hl(0, 'CmpItemMenu', { fg = '#C792EA', bg = 'NONE', italic = true })

            vim.api.nvim_set_hl(0, 'CmpItemKindField', { fg = '#B5585F' })
            vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { fg = '#B5585F' })
            vim.api.nvim_set_hl(0, 'CmpItemKindEvent', { fg = '#B5585F' })

            vim.api.nvim_set_hl(0, 'CmpItemKindText', { fg = '#9FBD73' })
            vim.api.nvim_set_hl(0, 'CmpItemKindEnum', { fg = '#9FBD73' })
            vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { fg = '#9FBD73' })

            vim.api.nvim_set_hl(0, 'CmpItemKindConstant', { fg = '#D4BB6C' })
            vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', { fg = '#D4BB6C' })
            vim.api.nvim_set_hl(0, 'CmpItemKindReference', { fg = '#D4BB6C' })

            vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = '#A377BF' })
            vim.api.nvim_set_hl(0, 'CmpItemKindStruct', { fg = '#A377BF' })
            vim.api.nvim_set_hl(0, 'CmpItemKindClass', { fg = '#A377BF' })
            vim.api.nvim_set_hl(0, 'CmpItemKindModule', { fg = '#A377BF' })
            vim.api.nvim_set_hl(0, 'CmpItemKindOperator', { fg = '#A377BF' })

            vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { fg = '#7E8294' })
            vim.api.nvim_set_hl(0, 'CmpItemKindFile', { fg = '#7E8294' })

            vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { fg = '#D4A959' })
            vim.api.nvim_set_hl(0, 'CmpItemKindSnippet', { fg = '#D4A959' })
            vim.api.nvim_set_hl(0, 'CmpItemKindFolder', { fg = '#D4A959' })

            vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { fg = '#6C8ED4' })
            vim.api.nvim_set_hl(0, 'CmpItemKindValue', { fg = '#6C8ED4' })
            vim.api.nvim_set_hl(0, 'CmpItemKindEnumMember', { fg = '#6C8ED4' })

            vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { fg = '#58B5A8' })
            vim.api.nvim_set_hl(0, 'CmpItemKindColor', { fg = '#58B5A8' })
            vim.api.nvim_set_hl(0, 'CmpItemKindTypeParameter', { fg = '#58B5A8' })
            cmp.config.formatting = { format = require('tailwindcss-colorizer-cmp').formatter }
            cmp.setup {
                view = { entries = 'bordered' },
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
                        winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:Visual,Search:None',
                    },
                    documentation = cmp.config.window.bordered { winhighlight = 'Normal:Normal,FloatBorder:LspBorderBG,CursorLine:PmenuSel,Search:None' },
                },
                sources = {
                    { name = 'calc' },
                    { name = 'nvim_lsp', max_item_count = 20, group_index = 1 },
                    { name = 'nvim_lsp_signature_help', group_index = 1 },
                    { name = 'buffer', keyword_length = 2, max_item_count = 5, group_index = 2 },
                    { name = 'path', group_index = 2 },
                    { name = 'spell', keyword_length = 4 },
                    { name = 'cody' },
                    { name = 'lazydev', group_index = 0 },
                    { name = 'luasnip', max_item_count = 5, group_index = 1 },
                    { name = 'nvim_lua', group_index = 1 },
                    { name = 'emoji' },
                },
                formatting = {
                    fields = { 'kind', 'abbr', 'menu' },
                    expandable_indicator = true,
                    format = function(entry, vim_item)
                        local _, lspkind = pcall(require, 'lspkind')
                        local devicons = require 'nvim-web-devicons'
                        local fmt = lspkind.cmp_format {
                            maxwidth = 70,
                            mode = 'symbol_text',
                            symbol_map = cmp_kinds,
                            show_labelDetails = true,
                            before = require("tailwind-tools.cmp").lspkind_format
                        }
                        local icon, hl_group = devicons.get_icon(entry:get_completion_item().label)
                        vim_item.kind_hl_group = hl_group or vim_item.kind_hl_group
                        local option = fmt(entry, vim_item)
                        local strings = vim.split(option.kind, '%s', { trimempty = true })
                        option.kind = ('' or '') .. ' ' .. (icon or strings[1] or '') .. ''
                        option.menu = '(' .. (option.menu or strings[2] or vim_item.menu) .. ')'
                        if entry.source.name == 'calc' then
                            option.kind = cmp_kinds.calc
                            option.menu = '(' .. (strings[2] or '') .. ')'
                        end
                        return option
                    end,
                },
                mapping = cmp.mapping.preset.insert {
                    ['<C-j>'] = cmp.mapping.select_next_item(),
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-k>'] = cmp.mapping.select_prev_item(),
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
