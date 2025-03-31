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
                "markdown-toc",
                "harper-ls",
                "prettier",
                "stylua",
                "isort",
                "black",
                "pylint",
                "eslint_d",
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
            "b0o/schemastore.nvim",
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
                end,
            })
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
                eslint = {
                    settings = {
                        format = true,
                        workingDirectories = { mode = "auto" },
                    },
                },
                stylua = {},
                dockerls = {},
                marksman = {},
                postgres_lsp = {},
                docker_compose_language_service = {},
                ts_ls = { enabled = false },
                tsserver = { enabled = false },
                vtsls = {
                    root_dir = lspconfig.util.root_pattern "package.json",
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
                            suggest = { completeFunctionCalls = true },
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
                                "ngClass",
                                "classList",
                                "className",
                                "container",
                                "class:list",
                                "containerClassName",
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
            require("lspconfig").harper_ls.setup {
                settings = {
                    ["harper-ls"] = {
                        userDictPath = "",
                        fileDictPath = "",
                        linters = {
                            SpellCheck = true,
                            SpelledNumbers = false,
                            AnA = true,
                            SentenceCapitalization = true,
                            UnclosedQuotes = true,
                            WrongQuotes = false,
                            LongSentences = true,
                            RepeatedWords = true,
                            Spaces = true,
                            Matcher = true,
                            CorrectNumberSuffix = true,
                        },
                        codeActions = {
                            ForceStable = false,
                        },
                        markdown = {
                            IgnoreLinkTitle = false,
                        },
                        diagnosticSeverity = "hint",
                        isolateEnglish = false,
                    },
                },
            }
            require("mason-tool-installer").setup { ensure_installed = servers }
            require("mason-lspconfig").setup {
                ensure_installed = servers,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            }
            -- require("typescript-tools").setup {
            --     settings = {
            --         separate_diagnostic_server = true,
            --         publish_diagnostic_on = "insert_leave",
            --         expose_as_code_action = {},
            --         tsserver_path = nil,
            --         tsserver_plugins = {},
            --         tsserver_max_memory = "auto",
            --         tsserver_format_options = {},
            --         tsserver_file_preferences = {},
            --         tsserver_locale = "en",
            --         complete_function_calls = false,
            --         include_completions_with_insert_text = true,
            --         code_lens = "on",
            --         disable_member_code_lens = true,
            --         jsx_close_tag = {
            --             enable = false,
            --             filetypes = { "javascriptreact", "typescriptreact" },
            --         },
            --     },
            -- }
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
            local function location_handler(_, result, ctx, _)
                if result == nil or vim.tbl_isempty(result) then
                    return nil
                end
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                assert(client)
                vim.lsp.util.jump_to_location(result, client.offset_encoding)
            end
            vim.lsp.handlers["textDocument/declaration"] = location_handler
            vim.lsp.handlers["textDocument/definition"] = location_handler
            vim.lsp.handlers["textDocument/typeDefinition"] = location_handler
            vim.lsp.handlers["textDocument/implementation"] = location_handler
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
            vim.lsp.handlers["textDocument/signatureHelp"] =
                vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.zig", "*.zon" },
                callback = function()
                    vim.lsp.buf.code_action {
                        context = { only = { "source.organizeImports" } },
                        apply = true,
                    }
                end,
            })
        end,
    },
}
