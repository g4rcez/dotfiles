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
        "neovim/nvim-lspconfig",
        dependencies = {
            "pmizio/typescript-tools.nvim",
            { "j-hui/fidget.nvim",       opts = {} },
            "williamboman/mason-lspconfig.nvim",
            { "williamboman/mason.nvim", opts = {} },
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
                    -- if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    --     local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", {
                    --         clear = false,
                    --     })
                    --     vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    --         buffer = event.buf,
                    --         group = highlight_augroup,
                    --         callback = vim.lsp.buf.document_highlight,
                    --     })
                    --
                    --     vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    --         buffer = event.buf,
                    --         group = highlight_augroup,
                    --         callback = vim.lsp.buf.clear_references,
                    --     })
                    --
                    --     vim.api.nvim_create_autocmd("LspDetach", {
                    --         group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                    --         callback = function(event2)
                    --             vim.lsp.buf.clear_references()
                    --             vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
                    --         end,
                    --     })
                    --     if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    --         map("<leader>th", function()
                    --             vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                    --         end, "[T]oggle Inlay [H]ints")
                    --     end
                    -- end
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
                vtsls = {},
                denols = {
                    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
                    settings = {
                        deno = {
                            enable = true,
                            suggest = { imports = { hosts = { ["https://deno.land"] = true } } },
                        },
                    },
                },
                stylua = {},
                dockerls = {},
                postgres_lsp = {},
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
