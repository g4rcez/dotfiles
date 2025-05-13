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
        "vuki656/package-info.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {},
        event = "BufRead package.json",
    },
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
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
            M.inlay_hints = { enabled = true }
            M.diagnostics = { virtual_text = { prefix = "icons" } }
            M.on_attach = function(_, bufnr)
                local function opts(desc)
                    return { buffer = bufnr, desc = "LSP " .. desc }
                end
                map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
                map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
                map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
                map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
                map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
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
            require("typescript-tools").setup {
                settings = {
                    separate_diagnostic_server = true,
                    publish_diagnostic_on = "insert_leave",
                    expose_as_code_action = {
                        "remove_unused_imports",
                        "organize_imports",
                    },
                    tsserver_path = nil,
                    tsserver_plugins = {},
                    tsserver_max_memory = "auto",
                    tsserver_format_options = {},
                    tsserver_file_preferences = {},
                    tsserver_locale = "en",
                    complete_function_calls = true,
                    include_completions_with_insert_text = true,
                    code_lens = "off",
                    disable_member_code_lens = true,
                    jsx_close_tag = { enable = true, filetypes = { "javascriptreact", "typescriptreact" } },
                },
            }
        end,
    },
}
