return {
    {
        enabled = false,
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {
            settings = {
                tsserver_file_preferences = {
                    includeInlayParameterNameHints = "all",
                    includeCompletionsForModuleExports = true,
                    quotePreference = "auto",
                },
                tsserver_format_options = {
                    allowIncompleteCompletions = false,
                    allowRenameOfImportPath = false,
                },
            },
        },
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        lazy = false,
        opts = {},
    },
    {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "folke/snacks.nvim" },
        },
        event = "LspAttach",
        opts = {
            backend = "delta",
            picker = "snacks",
            backend_opts = {
                diffsofancy = { header_lines_to_remove = 4 },
                delta = { header_lines_to_remove = 4, args = { "--line-numbers" } },
                difftastic = {
                    header_lines_to_remove = 1,
                    args = {
                        "--color=always",
                        "--display=inline",
                        "--syntax-highlight=on",
                    },
                },
            },
            resolve_timeout = 100,
            signs = {
                quickfix = { "", { link = "DiagnosticWarning" } },
                others = { "", { link = "DiagnosticWarning" } },
                refactor = { "", { link = "DiagnosticInfo" } },
                ["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
                ["refactor.extract"] = { "", { link = "DiagnosticError" } },
                ["source.organizeImports"] = { "", { link = "DiagnosticWarning" } },
                ["source.fixAll"] = { "󰃢", { link = "DiagnosticError" } },
                ["source"] = { "", { link = "DiagnosticError" } },
                ["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
                ["codeAction"] = { "", { link = "DiagnosticWarning" } },
            },
        },
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                "lazy.nvim",
                words = { "Lazy" },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "b0o/SchemaStore.nvim",
            "mason-org/mason-lspconfig.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            { "mason-org/mason.nvim", opts = {} },
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
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
                        local highlight_augroup =
                            vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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
                    local lspconfig_defaults = require("lspconfig").util.default_config
                    lspconfig_defaults.capabilities = vim.tbl_deep_extend(
                        "force",
                        lspconfig_defaults.capabilities,
                        require("blink.cmp").get_lsp_capabilities()
                    )
                end,
            })
        end,
    },
}
