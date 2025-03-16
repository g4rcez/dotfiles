return {
    { "folke/tokyonight.nvim", priority = 1000 },
    { "MunifTanjim/nui.nvim",  lazy = true },
    {
        "echasnovski/mini.icons",
        lazy = true,
        opts = {
            file = {
                [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
                ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
            },
            filetype = {
                dotenv = { glyph = "", hl = "MiniIconsYellow" },
            },
        },
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
    {
        "stevearc/aerial.nvim",
        opts = {},
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "echasnovski/mini.icons",
        },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup {
                flavour = "mocha",              -- latte, frappe, macchiato, mocha
                transparent_background = false, -- disables setting the background color.
                show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
                term_colors = true,             -- sets terminal colors (e.g. `g:terminal_color_0`)
                dim_inactive = {
                    enabled = true,             -- dims the background color of inactive window
                    shade = "dark",
                    percentage = 0.15,          -- percentage of the shade to apply to the inactive window
                },
                no_italic = false,
                no_bold = false,
                no_underline = false,
                styles = { comments = { "italic" }, conditionals = { "italic" } },
                default_integrations = true,
                integrations = {
                    mason = true,
                    aerial = true,
                    barbar = true,
                    gitsigns = true,
                    nvimtree = true,
                    blink_cmp = true,
                    treesitter = true,
                    mini = { enabled = true, indentscope_color = "" },
                },
            }
            vim.cmd.colorscheme "catppuccin-mocha"
        end,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        config = function()
            require("noice").setup {
                lsp = {
                    override = {
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    },
                },
                presets = {
                    bottom_search = true,
                    command_palette = true,
                    long_message_to_split = true,
                    inc_rename = false,
                    lsp_doc_border = true,
                },
            }
        end,
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {
            options = {
                mode = "buffers",
                themable = true,
                numbers = "none",
                diagnostics = "nvim_lsp",
                color_icons = true,
                separator_style = "thin",
                enforce_regular_tabs = true,
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "auto",
                ignore_focus = {},
                globalstatus = true,
                icons_enabled = true,
                section_separators = '',
                always_show_tabline = true,
                component_separators = '|',
                always_divide_middle = true,
                disabled_filetypes = { statusline = {}, winbar = {} },
                refresh = { statusline = 100, tabline = 100, winbar = 100 },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    "diff",
                    {
                        "diagnostics",
                        sources = { 'nvim_diagnostic' }
                    }
                },
                lualine_c = { "filename" },
                lualine_x = { "encoding", "fileformat", "filetype", "branch" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },
}
