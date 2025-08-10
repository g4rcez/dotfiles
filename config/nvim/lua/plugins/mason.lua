return {
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed or {}, {
                "astro-language-server",
                "bash-language-server",
                "codespell",
                "commitlint",
                "cspell",
                "css-lsp",
                "css-variables-language-server",
                "cssmodules-language-server",
                "deno",
                "diagnostic-languageserver",
                "docker-compose-language-service",
                "docker-language-server",
                "dockerfile-language-server",
                "emmet-ls",
                "gh-actions-language-server",
                "graphql-language-service-cli",
                "html-lsp",
                "jq",
                "json-lsp",
                "nextls",
                "prettierd",
                "rust-analyzer",
                "rustywind",
                "shellcheck",
                "tailwindcss-language-server",
                "vtsls",
                "yamlfmt",
            })
            return opts
        end,
    },
    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
    },
    { "williamboman/mason-lspconfig.nvim", opts = {} },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {},
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            automatic_installation = true,
            handlers = {},
            ensure_installed = {},
        },
    },
}
