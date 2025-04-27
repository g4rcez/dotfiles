local languages = {
    "ast_grep",
    "jsonls",
    "html",
    "harper_ls",
    "lua_ls",
    "tailwindcss",
    "sqlls",
    "vtsls",
    "gh_actions_ls",
    "dockerls",
    "css_variables",
    "bashls",
    "emmet_language_server",
    "cssls",
    "docker_compose_language_service",
    "denols",
    "yamlls",
}

return {
    "kabouzeid/nvim-lspinstall",
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
        opts = {
            ensure_installed = {
                "black",
                "eslint",
                "eslint_d",
                "harper-ls",
                "isort",
                "markdown-toc",
                "prettier",
                "pylint",
                "stylua",
                "vtsls",
            },
        },
    },
    {
        "vuki656/package-info.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {},
        event = "BufRead package.json",
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
            local map = vim.keymap.set
            M.on_attach = function(_, bufnr)
                local function opts(desc)
                    return { buffer = bufnr, desc = "LSP " .. desc }
                end
                map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
                map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
                map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
                map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
                map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
                map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")
            end
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
            local setupArgs = { capabilities = M.capabilities, on_init = M.on_init }
            for _, language in ipairs(languages) do
                lspconfig[language].setup(setupArgs)
                opts.servers[language] = {}
            end
            for server, config in pairs(opts.servers) do
                config.capabilities =
                    vim.tbl_deep_extend("force", M.capabilities, require("blink.cmp").get_lsp_capabilities({}, false))
                lspconfig[server].setup(config)
            end
        end,
    },
}
