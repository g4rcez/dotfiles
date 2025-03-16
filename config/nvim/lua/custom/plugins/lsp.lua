return {
    "kabouzeid/nvim-lspinstall",
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {},
    },
    {
        "b0o/schemastore.nvim",
        config = function()
            local schemas = require "schemastore"
            require("lspconfig").jsonls.setup {
                settings = {
                    yaml = {
                        schemas = schemas.yaml.schemas(),
                        validate = { enable = true },
                    },
                    json = {
                        schemas = schemas.json.schemas(),
                        validate = { enable = true },
                    },
                },
            }
        end,
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
        opts = {
            ensure_installed = { "markdown-toc" }
        }
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "pmizio/typescript-tools.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction", { "n", "x" })
                    map("gD", vim.lsp.buf.declaration, "[g]oto [d]eclaration")
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                end,
            })
            -- Diagnostic Config
            -- See :help vim.diagnostic.Opts
            vim.diagnostic.config {
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = vim.g.have_nerd_font and {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN] = "󰀪 ",
                        [vim.diagnostic.severity.INFO] = "󰋽 ",
                        [vim.diagnostic.severity.HINT] = "󰌶 ",
                    },
                } or {},
                virtual_text = {
                    source = "if_many",
                    spacing = 2,
                    format = function(diagnostic)
                        local diagnostic_message = {
                            [vim.diagnostic.severity.ERROR] = diagnostic.message,
                            [vim.diagnostic.severity.WARN] = diagnostic.message,
                            [vim.diagnostic.severity.INFO] = diagnostic.message,
                            [vim.diagnostic.severity.HINT] = diagnostic.message,
                        }
                        return diagnostic_message[diagnostic.severity]
                    end,
                },
            }
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local lspconfig = require "lspconfig"
            local servers = {
                html = {},
                cssls = {},
                bashls = {},
                eslint = {},
                stylua = {},
                dockerls = {},
                marksman = {},
                postgres_lsp = {},
                ts_ls = { enabled = false },
                tsserver = { enabled = false },
                docker_compose_language_service = {},
                vtsls = {
                    filetypes = {
                        "javascript",
                        "javascriptreact",
                        "javascript.jsx",
                        "typescript",
                        "typescriptreact",
                        "typescript.tsx",
                    },
                    settings = {
                        complete_function_calls = true,
                        vtsls = {
                            enableMoveToFileCodeAction = true,
                            autoUseWorkspaceTsdk = true,
                            experimental = {
                                maxInlayHintLength = 30,
                                completion = {
                                    enableServerSideFuzzyMatch = true,
                                },
                            },
                        },
                        typescript = {
                            updateImportsOnFileMove = { enabled = "always" },
                            suggest = {
                                completeFunctionCalls = true,
                            },
                            inlayHints = {
                                enumMemberValues = { enabled = true },
                                functionLikeReturnTypes = { enabled = true },
                                parameterNames = { enabled = "literals" },
                                parameterTypes = { enabled = true },
                                propertyDeclarationTypes = { enabled = true },
                                variableTypes = { enabled = false },
                            },
                        },
                    },
                },
                denols = {
                    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
                    settings = {
                        deno = {
                            enable = true,
                            suggest = { imports = { hosts = { ["https://deno.land"] = true } } },
                        },
                    },
                },
                tailwindcss = {
                    settings = {
                        tailwindCSS = {
                            validate = true,
                            classAttributes = {
                                "class",
                                "container",
                                "className",
                                "class:list",
                                "classList",
                                "ngClass",
                            },
                        },
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
            }
            require("typescript-tools").setup {
                settings = {
                    complete_function_calls = true,
                    separate_diagnostic_server = true,
                    tsserver_file_preferences = {
                        includeInlayParameterNameHints = "all",
                        includeCompletionsForModuleExports = true,
                    },
                    tsserver_format_options = {
                        allowIncompleteCompletions = false,
                        allowRenameOfImportPath = false,
                    },
                },
            }
            require("mason-tool-installer").setup { ensure_installed = servers }
            require("mason-lspconfig").setup {
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            }
            local function location_handler(_, result, ctx, _)
                if result == nil or vim.tbl_isempty(result) then
                    return nil
                end
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                assert(client)
                local has_telescope = pcall(require, "telescope")
                if vim.islist(result) then
                    if all_locations_equal(result) then
                        pcall(vim.lsp.util.jump_to_location, result[1], client.offset_encoding, false)
                    else
                        vim.fn.setloclist(0, {}, " ", {
                            title = "LSP locations",
                            items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
                        })
                        vim.cmd.lopen()
                    end
                else
                    vim.lsp.util.jump_to_location(result, client.offset_encoding)
                end
            end
            vim.lsp.handlers["textDocument/declaration"] = location_handler
            vim.lsp.handlers["textDocument/definition"] = location_handler
            vim.lsp.handlers["textDocument/typeDefinition"] = location_handler
            vim.lsp.handlers["textDocument/implementation"] = location_handler

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help,
                { border = "rounded" })
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.zig", "*.zon" },
                callback = function(ev)
                    vim.lsp.buf.code_action {
                        context = { only = { "source.organizeImports" } },
                        apply = true,
                    }
                end,
            })
        end,
    },
}
