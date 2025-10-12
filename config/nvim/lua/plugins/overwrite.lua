return {
    { "nvim-lualine/lualine.nvim", enabled = false,    event = "VeryLazy", },
    { "folke/flash.nvim",          event = "VeryLazy", enabled = false, },
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "deno",
                "shfmt",
                "flake8",
                "stylua",
                "harper-ls",
                "shellcheck",
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "bash",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "tsx",
                "typescript",
                "vim",
                "yaml",
                "tsx",
                "typescript",
            },
        },
    },
}
