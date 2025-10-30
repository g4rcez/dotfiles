return {
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        build = ':TSUpdate',
        opts = {
            enable = true,
            multiwindow = true,
            max_lines = 2,
            min_window_height = 0,
            line_numbers = true,
            multiline_threshold = 20,
            trim_scope = "outer",
            mode = "cursor",
            separator = nil,
            zindex = 20,
            on_attach = nil,
            ensure_installed = { "dockerfile" }
        },
    },
    {
        "andymass/vim-matchup",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = function(_, opts)
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
            -- require("nvim-treesitter.configs").setup { matchup = { enable = true } }
            return opts
        end,
    },
}
