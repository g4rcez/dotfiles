require("nvim-treesitter.configs").setup({
    matchup = {
        enable = true, -- mandatory, false will disable the whole extension
        disable = { }, -- optional, list of language that will be disabled
    },
})

return {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
        vim.list_extend(opts.ensure_installed, {
            "bash",
            "c",
            "css",
            "dockerfile",
            "git_config",
            "git_rebase",
            "gitignore",
            "html",
            "http",
            "javascript",
            "jsdoc",
            "json",
            "kdl",
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
        })
    end,
}
