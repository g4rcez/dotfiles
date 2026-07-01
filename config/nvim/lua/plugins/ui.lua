return {
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
                lsp_doc_border = true,
                command_palette = true,
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
                bufferline = true,
                indent_blankline = { enabled = true },
                navic = { enabled = true, custom_bg = "lualine" },
            },
        },
    },
}
