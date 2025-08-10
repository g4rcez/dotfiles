return {
    "kabouzeid/nvim-lspinstall",
    { "dnlhc/glance.nvim", cmd = "Glance" },
    {
        "nvimdev/lspsaga.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional
            "nvim-tree/nvim-web-devicons", -- optional
        },
        opts = {
            ui = {
                enable = false,
                code_action = "",
            },
        },
    },
    { "bezhermoso/tree-sitter-ghostty", build = "make nvim_install" },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "lazy.nvim", words = { "Lazy" } },
            },
        },
    },
    {
        opts = {},
        "vuki656/package-info.nvim",
        event = "BufRead package.json",
        dependencies = { "MunifTanjim/nui.nvim" },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "j-hui/fidget.nvim",
            "b0o/schemastore.nvim",
        },
        config = function(_, opts)
            local M = {}
            vim.lsp.handlers["textDocument/publishDiagnostics"] =
                vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
                    underline = true,
                    virtual_text = {
                        spacing = 5,
                        severity_limit = "Warning",
                    },
                    update_in_insert = true,
                })
            M.inlay_hints = { enabled = true }
            M.diagnostics = { virtual_text = { prefix = "icons" } }
            M.on_init = function(client, _)
                if client.supports_method "textDocument/semanticTokens" then
                    client.server_capabilities.semanticTokensProvider = nil
                end
            end
            M.capabilities = vim.lsp.protocol.make_client_capabilities()
            M.capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }
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
            opts.servers.vtsls = opts.servers.vtsls or {}
            opts.servers.vtsls.init_options = {
                typescript = {
                    unstable = {
                        organizeImportsLocale = "en",
                        organizeImportsCaseFirst = false,
                        organizeImportsIgnoreCase = "auto",
                        organizeImportsCollation = "unicode",
                        organizeImportsAccentCollation = true,
                        organizeImportsNumericCollation = true,
                    },
                },
            }
            for server, config in pairs(opts.servers) do
                config.capabilities =
                    vim.tbl_deep_extend("force", M.capabilities, require("blink.cmp").get_lsp_capabilities({}, false))
                lspconfig[server].setup(config)
            end
            return opts
        end,
    },
}
