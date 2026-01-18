return {
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        ---@class tokyonight.Config
        ---@field on_colors fun(colors: ColorScheme)
        ---@field on_highlights fun(highlights: tokyonight.Highlights, colors: ColorScheme)
        opts = { style = "night" },
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        cond = not require("config.vscode").isVscode(),
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                },
            },
            presets = {
                inc_rename = true,
                bottom_search = false,
                command_palette = true,
                lsp_doc_border = false,
                long_message_to_split = true,
            },
        },
    },
    {
        "2kabhishek/nerdy.nvim",
        cmd = "Nerdy",
        dependencies = { "folke/snacks.nvim" },
        opts = { max_recents = 30, add_default_keybindings = true, copy_to_clipboard = false, copy_register = "+" },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "catppuccin-mocha"
        end,
        opts = {
            flavour = "mocha",
            auto_integrations = true,
            lsp_styles = {
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                    ok = { "italic" },
                },
                underlines = {
                    errors = { "underline" },
                    hints = { "underline" },
                    warnings = { "underline" },
                    information = { "underline" },
                    ok = { "underline" },
                },
                inlay_hints = {
                    background = true,
                },
            },
            integrations = {
                cmp = true,
                fzf = true,
                leap = true,
                mini = true,
                alpha = true,
                flash = true,
                mason = true,
                noice = true,
                aerial = true,
                snacks = true,
                neotest = true,
                neotree = true,
                gitsigns = true,
                grug_far = true,
                nvimtree = true,
                blink_cmp = true,
                dashboard = true,
                headlines = true,
                telescope = true,
                which_key = true,
                illuminate = true,
                lsp_trouble = true,
                treesitter_context = true,
                indent_blankline = { enabled = true },
                navic = { enabled = true, custom_bg = "lualine" },
            },
        },
    },
    {
        "Bekaboo/dropbar.nvim",
        cond = not require("config.vscode").isVscode(),
        event = "UIEnter",
        opts = {
            bar = { padding = { left = 8, right = 2 } },
        },
        config = function()
            local dropbar_api = require "dropbar.api"
            vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
            vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
            vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
        end,
    },
}
