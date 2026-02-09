local vscode = require "config.vscode"

return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "j-hui/fidget.nvim" },
            { "mason-org/mason.nvim" },
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { cond = not require("config.vscode").isVscode(), "saghen/blink.cmp" },
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("nvim-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
                    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
                    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                    map("K", function()
                        vim.lsp.buf.hover { border = "rounded", focusable = true, wrap = true }
                    end, "Hover")
                    ---@param client vim.lsp.Client
                    ---@param method vim.lsp.protocol.Method
                    ---@param bufnr? integer some lsp support methods only in specific files
                    ---@return boolean
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has "nvim-0.11" == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
                            end,
                        })
                    end

                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map("<leader>th", function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, "[T]oggle Inlay [H]ints")
                    end
                end,
            })
            if not vscode.isVscode() then
                local capabilities = require("blink.cmp").get_lsp_capabilities()
                local servers = {
                    eslint = {
                        on_new_config = function(config, root_dir)
                            local has_config = #vim.fs.find({
                                "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs",
                                ".eslintrc", ".eslintrc.js", ".eslintrc.cjs",
                                ".eslintrc.json", ".eslintrc.yml", ".eslintrc.yaml",
                            }, { path = root_dir, upward = true, limit = 1 }) > 0
                            if not has_config then
                                config.enabled = false
                            end
                        end,
                        settings = {
                            eslint = {
                                experimental = { useFlatConfig = true },
                            },
                        },
                    },
                }
                local ensure_installed = vim.tbl_keys( {})
                vim.list_extend(ensure_installed, { "stylua" })
                require("mason-tool-installer").setup { ensure_installed = ensure_installed }
                require("mason-lspconfig").setup {
                    ensure_installed = require('config.ensure-installed').lsp,
                    automatic_installation = true,
                    handlers = {
                        function(server_name)
                            local server = servers[server_name] or {}
                            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                            require("lspconfig")[server_name].setup(server)
                        end,
                    },
                }
            end
        end,
    },
}
