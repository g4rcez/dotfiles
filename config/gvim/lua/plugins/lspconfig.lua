return {
    {
        "neovim/nvim-lspconfig",
        opts_extend = { "servers.*.keys" },
        dependencies = {
            "b0o/SchemaStore.nvim",
            { "j-hui/fidget.nvim",    opts = {} },
            { "mason-org/mason.nvim", opts = {} },
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "mason-org/mason-lspconfig.nvim", config = function() end },
        },
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                setup = {},
                folds = { enabled = true },
                codelens = { enabled = true },
                inlay_hints = { enabled = true },
            })
        end,
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
                        border = "rounded",
                        width = 100,
                        height = 30,
                    })
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight",
                            { clear = false })
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
                    map("<leader>ch", function()
                        vim.lsp.inlay_hint.enable(false)
                        Snacks.toggle.inlay_hints()
                    end, "[c]ode [h]ints")

                    vim.api.nvim_create_autocmd({ "FileType" }, {
                        pattern = "css,eruby,html,htmldjango,javascriptreact,less,pug,sass,scss,typescriptreact",
                        callback = function()
                            vim.lsp.start {
                                cmd = { "emmet-language-server", "--stdio" },
                                root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
                                init_options = {
                                    showSuggestionsAsSnippets = true,
                                    showAbbreviationSuggestions = true,
                                    showExpandedAbbreviation = "inMarkupAndStylesheetFilesOnly",
                                },
                            }
                        end,
                    })

                    local lspconfig_defaults = require("lspconfig").util.default_config
                    local capabilities = vim.lsp.protocol.make_client_capabilities()
                    capabilities.textDocument.completion.completionItem.snippetSupport = true
                    lspconfig_defaults.capabilities = vim.tbl_deep_extend(
                        "force",
                        lspconfig_defaults.capabilities,
                        vim.tbl_deep_extend("force", require("blink.cmp").get_lsp_capabilities(), capabilities)
                    )
                end,
            })
        end,
    }
}
