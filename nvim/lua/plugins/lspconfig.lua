local icons = {
    kind = {
        Array = " ",
        Boolean = " ",
        Class = " ",
        Color = " ",
        Constant = " ",
        Constructor = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Folder = "󰉋 ",
        Function = " ",
        Interface = " ",
        Key = " ",
        Keyword = " ",
        Method = " ",
        -- Module = " ",
        Module = " ",
        Namespace = " ",
        Null = "󰟢 ",
        Number = " ",
        Object = " ",
        Operator = " ",
        Package = " ",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        String = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = " ",
        Value = " ",
        Variable = " ",
    },
    git = {
        LineAdded = " ",
        LineModified = " ",
        LineRemoved = " ",
        FileDeleted = " ",
        FileIgnored = "◌",
        FileRenamed = " ",
        FileStaged = "S",
        FileUnmerged = "",
        FileUnstaged = "",
        FileUntracked = "U",
        Diff = " ",
        Repo = " ",
        Octoface = " ",
        Copilot = " ",
        Branch = "",
    },
    ui = {
        ArrowCircleDown = " ",
        ArrowCircleLeft = " ",
        ArrowCircleRight = " ",
        ArrowCircleUp = " ",
        BoldArrowDown = " ",
        BoldArrowLeft = " ",
        BoldArrowRight = " ",
        BoldArrowUp = " ",
        BoldClose = " ",
        BoldDividerLeft = "",
        BoldDividerRight = "",
        BoldLineLeft = "▎",
        BoldLineMiddle = "┃",
        BoldLineDashedMiddle = "┋",
        BookMark = "",
        BoxChecked = " ",
        Bug = " ",
        Stacks = "",
        Scopes = "",
        Watches = "󰂥",
        DebugConsole = " ",
        Calendar = " ",
        Check = " ",
        ChevronRight = "",
        ChevronShortDown = "",
        ChevronShortLeft = "",
        ChevronShortRight = "",
        ChevronShortUp = "",
        Circle = " ",
        Close = "󰅖 ",
        CloudDownload = " ",
        Code = " ",
        Comment = " ",
        Dashboard = " ",
        DividerLeft = "",
        DividerRight = "",
        DoubleChevronRight = "»",
        Ellipsis = "",
        EmptyFolder = " ",
        EmptyFolderOpen = " ",
        File = " ",
        FileSymlink = "",
        Files = " ",
        FindFile = "󰈞 ",
        FindText = "󰊄 ",
        Fire = "",
        Folder = "󰉋 ",
        FolderOpen = " ",
        FolderSymlink = " ",
        Forward = " ",
        Gear = " ",
        History = " ",
        Lightbulb = " ",
        LineLeft = "▏",
        LineMiddle = "│",
        List = " ",
        Lock = " ",
        NewFile = " ",
        Note = " ",
        Package = " ",
        Pencil = "󰏫 ",
        Plus = " ",
        Project = " ",
        Search = " ",
        SignIn = " ",
        SignOut = " ",
        Tab = "󰌒 ",
        Table = " ",
        Target = "󰀘 ",
        Telescope = " ",
        Text = " ",
        Tree = "",
        Triangle = "󰐊",
        TriangleShortArrowDown = "",
        TriangleShortArrowLeft = "",
        TriangleShortArrowRight = "",
        TriangleShortArrowUp = "",
    },
    diagnostics = {
        BoldError = " ",
        Error = " ",
        BoldWarning = " ",
        Warning = " ",
        BoldInformation = " ",
        Information = " ",
        BoldQuestion = " ",
        Question = " ",
        BoldHint = "",
        Hint = "󰌶",
        Debug = " ",
        Trace = "✎",
    },
    misc = {
        Robot = "󰚩 ",
        Squirrel = " ",
        Tag = " ",
        Watch = "",
        Smiley = " ",
        Package = " ",
        CircuitBoard = " ",
    },
}

local M = {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { { "folke/neodev.nvim" } },
    opts = {
        inlay_hints = { enabled = true },
        servers = {
            bashls = {},
            clangd = {},
            cssls = {},
            dockerls = {},
            html = {},
            tailwindcss = { filetypes_exclude = { "markdown" }, filetypes_include = {} },
            tsserver = {
                keys = {
                    {
                        "<leader>co",
                        function()
                            vim.lsp.buf.code_action({
                                apply = true,
                                context = {
                                    only = { "source.organizeImports.ts" },
                                    diagnostics = {},
                                },
                            })
                        end,
                        desc = "Organize Imports",
                    },
                    {
                        "<leader>cR",
                        function()
                            vim.lsp.buf.code_action({
                                apply = true,
                                context = {
                                    only = { "source.removeUnused.ts" },
                                    diagnostics = {},
                                },
                            })
                        end,
                        desc = "Remove Unused Imports",
                    },
                },
                settings = {
                    typescript = {
                        format = {
                            indentSize = vim.o.shiftwidth,
                            convertTabsToSpaces = vim.o.expandtab,
                            tabSize = vim.o.tabstop,
                        },
                    },
                    javascript = {
                        format = {
                            indentSize = vim.o.shiftwidth,
                            convertTabsToSpaces = vim.o.expandtab,
                            tabSize = vim.o.tabstop,
                        },
                    },
                    completions = {
                        completeFunctionCalls = true,
                    },
                },
            },
        },
        setup = {
            tsserver = {},
            tailwindcss = function(_, opts)
                local tw = require("lspconfig.server_configurations.tailwindcss")
                opts.filetypes = opts.filetypes or {}
                -- Add default filetypes
                vim.list_extend(opts.filetypes, tw.default_config.filetypes)
                -- Remove excluded filetypes
                --- @param ft string
                opts.filetypes = vim.tbl_filter(function(ft)
                    return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
                end, opts.filetypes)
                -- Add additional filetypes
                vim.list_extend(opts.filetypes, opts.filetypes_include or {})
            end,
        },
    },
}

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true }
    local keymap = vim.api.nvim_buf_set_keymap
    keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
end

M.on_attach = function(client, bufnr)
    lsp_keymaps(bufnr)
    if client.supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(bufnr, true)
    end
end

M.toggle_inlay_hints = function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
end

function M.common_capabilities()
    local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if status_ok then
        return cmp_nvim_lsp.default_capabilities()
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    }
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }

    return capabilities
end

function M.config()
    local lspconfig = require("lspconfig")
    local servers = {
        "lua_ls",
        "cssls",
        "html",
        "tsserver",
        "bashls",
        "jsonls",
        "yamlls",
        "marksman",
        "tailwindcss",
    }

    local default_diagnostic_config = {
        signs = {
            active = true,
            values = {
                { name = "DiagnosticSignError", text = icons.diagnostics.Error },
                { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
                { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
                { name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
            },
        },
        virtual_text = false,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
            focusable = true,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    }

    vim.diagnostic.config(default_diagnostic_config)

    for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
    end

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
    vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
    require("lspconfig.ui.windows").default_options.border = "rounded"

    for _, server in pairs(servers) do
        local opts = {
            on_attach = M.on_attach,
            capabilities = M.common_capabilities(),
        }

        local require_ok, settings = pcall(require, "config.lspsettings." .. server)
        if require_ok then
            opts = vim.tbl_deep_extend("force", settings, opts)
        end

        if server == "lua_ls" then
            require("neodev").setup({})
        end

        lspconfig[server].setup(opts)
    end
end

return M
