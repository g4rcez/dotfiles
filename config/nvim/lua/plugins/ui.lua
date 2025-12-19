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
                inc_rename = false,
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
        cond = not require("config.vscode").isVscode(),
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
