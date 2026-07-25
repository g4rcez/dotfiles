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
        "folke/tokyonight.nvim",
        priority = 1000,
        opts = {
            style = "night",
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
            },
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme "tokyonight-night"
        end,
    },
}
