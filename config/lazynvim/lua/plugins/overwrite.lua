return {
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
                "css",
                "editorconfig",
                "html",
                "javascript",
                "json",
                "json5",
                "jsonc",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "styled",
                "tsx",
                "typescript",
                "vim",
                "yaml",
            },
        },
    },
}
