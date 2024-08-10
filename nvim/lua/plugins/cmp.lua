local icons = {
    Array = ' ',
    Boolean = ' ',
    Class = ' ',
    Color = ' ',
    Constant = ' ',
    Constructor = '',
    Enum = ' ',
    EnumMember = '',
    Event = ' ',
    Field = ' ',
    File = '',
    Folder = ' ',
    Function = '󰊕',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = ' ',
    Module = ' ',
    Namespace = ' ',
    Null = '󰟢',
    Number = ' ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = '󰜢',
    Reference = ' ',
    Snippet = ' ',
    String = ' ',
    Struct = ' ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = '',
    Value = ' ',
    Variable = ' ',
    calc = '󰃬',
}

local allIcons = {
    kind = icons,
    git = {
        LineAdded = '',
        LineModified = '',
        LineRemoved = '',
        FileDeleted = '',
        FileIgnored = '◌',
        FileRenamed = '',
        FileStaged = 'S',
        FileUnmerged = '',
        FileUnstaged = '',
        FileUntracked = 'U',
        Diff = '',
        Repo = '',
        Octoface = '',
        Copilot = '',
        Branch = '',
    },
    ui = {
        ArrowCircleDown = '',
        ArrowCircleLeft = '',
        ArrowCircleRight = '',
        ArrowCircleUp = '',
        BoldArrowDown = '',
        BoldArrowLeft = '',
        BoldArrowRight = '',
        BoldArrowUp = '',
        BoldClose = '',
        BoldDividerLeft = '',
        BoldDividerRight = '',
        BoldLineLeft = '▎',
        BoldLineMiddle = '┃',
        BoldLineDashedMiddle = '┋',
        BookMark = '',
        BoxChecked = '',
        Bug = '',
        Stacks = '',
        Scopes = '',
        Watches = '󰂥',
        DebugConsole = '',
        Calendar = '',
        Check = '',
        ChevronRight = '',
        ChevronShortDown = '',
        ChevronShortLeft = '',
        ChevronShortRight = '',
        ChevronShortUp = '',
        Circle = '',
        Close = '󰅖',
        CloudDownload = '',
        Code = '',
        Comment = '',
        Dashboard = '',
        DividerLeft = '',
        DividerRight = '',
        DoubleChevronRight = '»',
        Ellipsis = '',
        EmptyFolder = '',
        EmptyFolderOpen = '',
        File = '',
        FileSymlink = '',
        Files = '',
        FindFile = '󰈞',
        FindText = '󰊄',
        Fire = '',
        Folder = '󰉋',
        FolderOpen = '',
        FolderSymlink = '',
        Forward = '',
        Gear = '',
        History = '',
        Lightbulb = '',
        LineLeft = '▏',
        LineMiddle = '│',
        List = '',
        Lock = '',
        NewFile = '',
        Note = '',
        Package = '',
        Pencil = '󰏫',
        Plus = '',
        Project = '',
        Search = '',
        SignIn = '',
        SignOut = '',
        Tab = '󰌒',
        Table = '',
        Target = '󰀘',
        Telescope = '',
        Text = '',
        Tree = '',
        Triangle = '󰐊',
        TriangleShortArrowDown = '',
        TriangleShortArrowLeft = '',
        TriangleShortArrowRight = '',
        TriangleShortArrowUp = '',
    },
    diagnostics = {
        BoldError = '',
        Error = '',
        BoldWarning = '',
        Warning = '',
        BoldInformation = '',
        Information = '',
        BoldQuestion = '',
        Question = '',
        BoldHint = '',
        Hint = '󰌶',
        Debug = '',
        Trace = '✎',
    },
    misc = {
        Robot = '󰚩',
        Squirrel = '',
        Tag = '',
        Watch = '',
        Smiley = '',
        Package = '',
        CircuitBoard = '',
    },
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
            {
                'garymjr/nvim-snippets',
                opts = {
                    friendly_snippets = true,
                },
                dependencies = { 'rafamadriz/friendly-snippets' },
            },
            {
                'L3MON4D3/LuaSnip',
                event = 'InsertEnter',
                dependencies = { 'rafamadriz/friendly-snippets' },
                build = 'make install_jsregexp',
            },
        },
        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            luasnip.config.setup {}
            require('luasnip.loaders.from_vscode').lazy_load()
            require('luasnip.loaders.from_snipmate').lazy_load()
            require('luasnip.loaders.from_vscode').lazy_load { paths = '~/.config/nvim/snippets' }
            luasnip.filetype_extend('typescriptreact', { 'html' })
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
            vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })
            local defaults = require 'cmp.config.default'()
            cmp.setup {
                auto_brackets = {},
                view = { entries = 'bordered' },
                experimental = { ghost_text = { hl_group = 'CmpGhostText' } },
                completion = { completeopt = 'menu,menuone,noinsert,noselect' },
                sorting = defaults.sorting,
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered {
                        col_offset = -3,
                        side_padding = 0,
                        winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:Visual,Search:None',
                    },
                    documentation = cmp.config.window.bordered { winhighlight = 'Normal:Normal,FloatBorder:LspBorderBG,CursorLine:PmenuSel,Search:None' },
                },
                sources = {
                    {
                        name = 'nvim_lsp',
                        entry_filter = function(entry, ctx)
                            local kind = require('cmp.types.lsp').CompletionItemKind[entry:get_kind()]
                            if ctx.prev_context.filetype == 'markdown' then
                                return true
                            end
                            if kind == 'Text' then
                                return false
                            end
                            return true
                        end,
                    },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'buffer' },
                    { name = 'path' },
                    { name = 'calc' },
                    { name = 'luasnip' },
                    { name = 'spell' },
                    { name = 'cody' },
                    { name = 'lazydev' },
                    { name = 'nvim_lua' },
                    { name = 'emoji' },
                },
                -- cmp.config.formatting = { format = require('tailwindcss-colorizer-cmp').formatter }
                formatting = {
                    fields = { 'kind', 'abbr', 'menu' },
                    expandable_indicator = true,
                    format = function(entry, item)
                        item.kind = icons[item.kind]
                        item.menu = ({
                            nvim_lsp = '',
                            nvim_lua = '',
                            luasnip = '',
                            buffer = '',
                            path = '',
                            emoji = '',
                        })[entry.source.name]
                        local color_item = require('nvim-highlight-colors').format(entry, { kind = item.kind })
                        item = require('lspkind').cmp_format {
                            mode = 'symbol_text',
                            symbol_map = icons,
                        }(entry, item)
                        if color_item.abbr_hl_group then
                            item.kind_hl_group = color_item.abbr_hl_group
                            item.kind = color_item.abbr
                        end
                        return item
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
