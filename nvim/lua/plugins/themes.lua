return {
    'nvim-tree/nvim-web-devicons',
    'NvChad/nvim-colorizer.lua',
    {
        'NvChad/nvim-colorizer.lua',
        lazy = false,
        event = 'User FilePost',
        opts = { user_default_options = { names = false }, filetypes = { '*', '!lazy' } },
        config = function(_, opts)
            local colorizer = require 'colorizer'
            opts.user_default_options = {
                mode = 'background',
                css = true,
            }
            colorizer.setup {
                RGB = true,
                RRGGBB = true,
                names = true,
                RRGGBBAA = true,
                AARRGGBB = true,
                rgb_fn = true,
                hsl_fn = true,
                css = true,
                css_fn = true,
                mode = 'background',
                tailwind = true,
                sass = { enable = true, parsers = { 'css' } }, -- Enable sass colors
                virtualtext = '■',
                always_update = 'cmp_menu',
            }
            colorizer.attach_to_buffer(0)
        end,
    },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        init = function()
            vim.opt.background = 'dark'
            vim.cmd 'colorscheme catppuccin'
        end,
        opts = {
            flavour = 'mocha',
            background = { light = 'latte', dark = 'mocha' },
            transparent_background = false,
            show_end_of_buffer = true,
            term_colors = false,
            dim_inactive = { enabled = false },
            no_italic = false,
            no_bold = false,
            no_underline = false,
            color_overrides = {
                mocha = {
                    base = '#1a1a2a',
                    mantle = '#1a1a2a',
                    crust = '#1a1a2a',
                },
            },
            styles = {
                comments = { 'italic' },
                functions = {},
                keywords = { 'italic' },
                operators = { 'bold' },
                conditionals = { 'bold' },
                loops = { 'bold' },
                booleans = { 'bold', 'italic' },
                numbers = {},
                types = {},
                strings = {},
                variables = {},
                properties = {},
            },
            custom_highlights = {},
            default_integrations = true,
            integrations = {
                alpha = true,
                barbar = false,
                cmp = true,
                gitsigns = true,
                ufo = true,
                noice = true,
                nvimtree = true,
                treesitter = true,
                notify = true,
                which_key = true,
                harpoon = true,
                lsp_saga = true,
                telescope = { enabled = true, style = 'nvchad' },
                mini = { enabled = true, indentscope_color = '' },
                indent_blankline = { enabled = true, scope_color = '', colored_indent_levels = true },
                native_lsp = {
                    enabled = true,
                    virtual_text = { errors = { 'italic' }, hints = { 'italic' }, warnings = { 'italic' }, information = { 'italic' }, ok = { 'italic' } },
                    underlines = {
                        errors = { 'underline' },
                        hints = { 'underline' },
                        warnings = { 'underline' },
                        information = { 'underline' },
                        ok = { 'underline' },
                    },
                    inlay_hints = { background = true },
                },
            },
        },
    },
    {
        'goolord/alpha-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local alpha = require 'alpha'
            local dashboard = require 'alpha.themes.dashboard'
            dashboard.section.header.val = {
                '                                                     ',
                '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
                '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
                '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
                '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
                '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
                '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
                '                                                     ',
            }
            -- Set menu
            dashboard.section.buttons.val = {
                dashboard.button('b', '  > Back Session', [[<cmd> lua require("persistence").load() <cr>]]),
                dashboard.button('e', '  > New file', ':ene <BAR> startinsert <CR>'),
                dashboard.button('f', '  > Find file', ':cd $PWD | Telescope find_files<CR>'),
                dashboard.button('q', '  > Quit NVIM', ':qa<CR>'),
                dashboard.button('r', '  > Recent', ':Telescope oldfiles<CR>'),
                dashboard.button('s', '  > Settings', ':e $MYVIMRC | :cd %:p:h<CR>'),
            }
            alpha.setup(dashboard.opts)
        end,
    },
}
