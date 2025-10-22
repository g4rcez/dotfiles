return {
    { "b0o/SchemaStore.nvim", lazy = true, version = false },
    {
        "mason-org/mason.nvim",
        build = ":MasonUpdate",
        opts_extend = { "ensure_installed" },
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed or {}, {
                "deno",
                "shfmt",
                "flake8",
                "stylua",
                "sqlfluff",
                "harper-ls",
                "shellcheck",
                "markdown-toc",
            })
            return opts
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    {
        enabled = false,
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "mason-org/mason.nvim", "nvimtools/none-ls.nvim" },
        opts = {},
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
        opts = {},
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            automatic_installation = true,
            handlers = {},
            ensure_installed = {},
        },
    },
}
