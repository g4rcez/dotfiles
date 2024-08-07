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
                sass = { enable = true, parsers = { 'css' } },
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
            term_colors = true,
            dim_inactive = { enabled = false },
            styles = {
                comments = { 'italic' },
                functions = { 'bold' },
                keywords = { 'italic' },
                operators = { 'bold' },
                conditionals = { 'bold' },
                loops = { 'bold' },
                booleans = { 'bold', 'italic' },
                numbers = { 'bold' },
                types = { 'bold' },
                strings = {},
                variables = {},
                properties = {},
            },
            custom_highlights = {},
            default_integrations = true,
            highlight_overrides = {
                all = function(colors)
                    return {
                        CurSearch = { bg = colors.sky },
                        IncSearch = { bg = colors.sky },
                        CursorLineNr = { fg = colors.blue, style = { 'bold' } },
                        DashboardFooter = { fg = colors.overlay0 },
                        TreesitterContextBottom = { style = {} },
                        WinSeparator = { fg = colors.overlay0, style = { 'bold' } },
                        ['@markup.italic'] = { fg = colors.blue, style = { 'italic' } },
                        ['@markup.strong'] = { fg = colors.blue, style = { 'bold' } },
                        Headline = { style = { 'bold' } },
                        Headline1 = { fg = colors.blue, style = { 'bold' } },
                        Headline2 = { fg = colors.pink, style = { 'bold' } },
                        Headline3 = { fg = colors.lavender, style = { 'bold' } },
                        Headline4 = { fg = colors.green, style = { 'bold' } },
                        Headline5 = { fg = colors.peach, style = { 'bold' } },
                        Headline6 = { fg = colors.flamingo, style = { 'bold' } },
                    }
                end,
            },
            color_overrides = {
                mocha = {
                    rosewater = '#efc9c2',
                    flamingo = '#ebb2b2',
                    pink = '#f2a7de',
                    mauve = '#b889f4',
                    red = '#ea7183',
                    maroon = '#ea838c',
                    peach = '#f39967',
                    yellow = '#eaca89',
                    green = '#96d382',
                    teal = '#78cec1',
                    sky = '#91d7e3',
                    sapphire = '#68bae0',
                    blue = '#739df2',
                    lavender = '#a0a8f6',
                    text = '#b5c1f1',
                    subtext1 = '#a6b0d8',
                    subtext0 = '#959ec2',
                    overlay2 = '#848cad',
                    overlay1 = '#717997',
                    overlay0 = '#63677f',
                    surface2 = '#505469',
                    surface1 = '#3e4255',
                    surface0 = '#2c2f40',
                    base = '#1a1c2a',
                    mantle = '#141620',
                    crust = '#0e0f16',
                },
            },
            integrations = {
                aerial = true,
                alpha = true,
                barbar = false,
                cmp = true,
                gitsigns = true,
                harpoon = true,
                lsp_saga = true,
                mason = true,
                neotree = true,
                noice = true,
                notify = true,
                nvimtree = true,
                treesitter = true,
                ufo = true,
                which_key = true,
                mini = { enabled = true },
                navic = { enabled = true },
                telescope = { enabled = true, style = 'nvchad' },
                indent_blankline = { enabled = true, colored_indent_levels = true },
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
