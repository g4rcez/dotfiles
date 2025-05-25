local languages = {
    "ast_grep",
    "bashls",
    "css_variables",
    "cssls",
    "denols",
    "docker_compose_language_service",
    "dockerls",
    "emmet_language_server",
    "gh_actions_ls",
    "harper_ls",
    "html",
    "jsonls",
    "lua_ls",
    "sqlls",
    "tailwindcss",
    "vtsls",
    "yamlls",
}

return {
    "kabouzeid/nvim-lspinstall",
    {
        "bezhermoso/tree-sitter-ghostty",
        build = "make nvim_install",
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed or {}, {
                "black",
                "css-lsp",
                "eslint",
                "eslint_d",
                "harper-ls",
                "isort",
                "luacheck",
                "markdown-toc",
                "prettier",
                "selene",
                "shellcheck",
                "shfmt",
                "stylua",
                "tailwindcss-language-server",
                "typescript-language-server",
                "vtsls",
            })
            return opts
        end,
    },
    {
        opts = {},
        "vuki656/package-info.nvim",
        event = "BufRead package.json",
        dependencies = { "MunifTanjim/nui.nvim" },
    },
    {
        "pmizio/typescript-tools.nvim",
        enabled = false,
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = function(_, opts)
            opts.ensure_installed = { "vtsls", "eslint" }
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = { "vtsls", "eslint-lsp", "prettierd", "js-debug-adapter" }
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "j-hui/fidget.nvim",
            "b0o/schemastore.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function(_, opts)
            local M = {}
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
            vim.lsp.handlers["textDocument/signatureHelp"] =
                vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
            M.inlay_hints = { enabled = true }
            M.diagnostics = { virtual_text = { prefix = "icons" } }
            M.on_init = function(client, _)
                if client.supports_method "textDocument/semanticTokens" then
                    client.server_capabilities.semanticTokensProvider = nil
                end
            end
            M.capabilities = vim.lsp.protocol.make_client_capabilities()
            M.capabilities.textDocument.completion.completionItem = {
                documentationFormat = { "markdown", "plaintext" },
                snippetSupport = true,
                preselectSupport = true,
                insertReplaceSupport = true,
                labelDetailsSupport = true,
                deprecatedSupport = true,
                commitCharactersSupport = true,
                tagSupport = { valueSet = { 1 } },
                resolveSupport = {
                    properties = {
                        "documentation",
                        "detail",
                        "additionalTextEdits",
                    },
                },
            }
            local lspconfig = require "lspconfig"
            opts.servers = opts.servers or {}
            for server, config in pairs(opts.servers) do
                config.capabilities =
                    vim.tbl_deep_extend("force", M.capabilities, require("blink.cmp").get_lsp_capabilities({}, false))
                lspconfig[server].setup(config)
            end
        end,
    },
}
