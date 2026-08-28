local keymap = vim.keymap
local severity = vim.diagnostic.severity

local function restart_lsp_clients(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    if vim.tbl_isempty(clients) then
        vim.notify("No LSP clients attached to this buffer", vim.log.levels.WARN)
        return
    end

    for _, client in ipairs(clients) do
        vim.lsp.stop_client(client.id, true)
    end

    vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.cmd "silent! edit"
        end
    end, 300)
end

local function lsp_client_names(bufnr)
    return vim.iter(vim.lsp.get_clients { bufnr = bufnr or vim.api.nvim_get_current_buf() })
        :map(function(client)
            return client.name
        end)
        :totable()
end

if vim.lsp.log and vim.lsp.log.set_level then
    vim.lsp.log.set_level(vim.log.levels.WARN)
end

vim.diagnostic.config {
    underline = false,
    severity_sort = true,
    virtual_text = true,
    update_in_insert = true,
    float = { border = "single", source = "if_many" },
    diagnostics = { underline = false, update_in_insert = true },
    signs = {
        text = {
            [severity.ERROR] = " ",
            [severity.WARN] = " ",
            [severity.HINT] = "󰠠 ",
            [severity.INFO] = " ",
        },
    },
}

vim.filetype.add {
    extension = {
        mdx = "mdx",
        http = "http",
        rasi = "rasi",
        rofi = "rasi",
        wofi = "rasi",
        vifmrc = "vim",
        txt = "markdown",
    },
    pattern = {
        ["%.env%.[%w_.-]+"] = "sh",
        [".*/mako/config"] = "dosini",
        [".*/waybar/config"] = "jsonc",
        [".*/kitty/.+%.conf"] = "kitty",
        [".*/hypr/.+%.conf"] = "hyprlang",
    },
}

vim.api.nvim_create_user_command("LspRestartBuffer", function()
    restart_lsp_clients()
end, { desc = "Restart LSP clients attached to the current buffer" })

vim.api.nvim_create_user_command("LspClients", function()
    local names = lsp_client_names()
    vim.notify(vim.tbl_isempty(names) and "No LSP clients attached" or ("LSP clients: " .. table.concat(names, ", ")))
end, { desc = "Show LSP clients attached to the current buffer" })

vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd("tabedit " .. vim.fn.fnameescape(vim.lsp.get_log_path()))
end, { desc = "Open the Neovim LSP log" })

vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("UserLspDetach", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client then
            vim.notify(("LSP detached: %s"):format(client.name), vim.log.levels.INFO)
        end
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", function()
            Snacks.picker.lsp_references()
        end, opts)

        opts.desc = "Show LSP definition"
        keymap.set("n", "gd", vim.lsp.buf.definition, opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", function()
            Snacks.picker.lsp_implementations()
        end, opts)

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", function()
            Snacks.picker.lsp_type_definitions()
        end, opts)

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Extract refactor"
        keymap.set({ "n", "v" }, "<leader>cx", function()
            vim.lsp.buf.code_action {
                context = { only = { "refactor.extract" } },
            }
        end, opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", function()
            Snacks.picker.diagnostics_buffer()
        end, opts)

        opts.desc = "Show cursor diagnostics"
        keymap.set("n", "<leader>dd", function()
            vim.diagnostic.open_float {
                scope = "cursor",
                source = "if_many",
                border = "rounded",
                focusable = false,
            }
        end, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", function()
            vim.diagnostic.jump { count = -1, severity = { min = vim.diagnostic.severity.WARN } }
        end, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", function()
            vim.diagnostic.jump { count = 1, severity = { min = vim.diagnostic.severity.WARN } }
        end, opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", function()
            vim.lsp.buf.hover { border = "single", focusable = true, wrap = true }
        end, opts)

        opts.desc = "Restart buffer LSP clients"
        keymap.set("n", "<leader>rs", function()
            restart_lsp_clients(ev.buf)
        end, opts)

        opts.desc = "Show attached LSP clients"
        keymap.set("n", "<leader>ci", "<cmd>LspClients<cr>", opts)

        opts.desc = "Open LSP log"
        keymap.set("n", "<leader>cl", "<cmd>LspLog<cr>", opts)

        opts.desc = "Toggle hints and diagnostics"
        keymap.set("n", "<leader>th", function()
            local hidden = not vim.b[ev.buf].hints_diagnostics_hidden
            vim.b[ev.buf].hints_diagnostics_hidden = hidden
            vim.lsp.inlay_hint.enable(not hidden, { bufnr = ev.buf })
            vim.diagnostic.enable(not hidden, { bufnr = ev.buf })
            vim.notify((hidden and "Hidden" or "Shown") .. " hints and diagnostics")
        end, opts)

        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        -- if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, ev.buf) then
        --     vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        -- end

        if
            client
            and not vim.b[ev.buf].lsp_document_highlight_enabled
            and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, ev.buf)
        then
            vim.b[ev.buf].lsp_document_highlight_enabled = true
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-document-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = ev.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = ev.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("lsp-document-detach", { clear = false }),
                buffer = ev.buf,
                once = true,
                callback = function(ev2)
                    vim.b[ev2.buf].lsp_document_highlight_enabled = false
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = "lsp-document-highlight", buffer = ev2.buf }
                end,
            })
        end
    end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
end

pcall(require, "lspconfig")

local function lsp_config(name, opts)
    opts = opts or {}
    opts.capabilities = opts.capabilities or capabilities
    vim.lsp.config(name, opts)
end

lsp_config "kulala_ls"
lsp_config "css_variables"
lsp_config "docker_compose_language_service"
lsp_config("denols", {
    root_markers = { "deno.json", "deno.jsonc" },
})
lsp_config("html", {
    filetypes = { "html" },
    cmd = { "vscode-html-language-server", "--stdio" },
})

lsp_config("emmet_ls", {
    cmd = { "emmet-ls", "--stdio" },
    root_markers = { "package.json" },
    filetypes = { "html", "css", "scss", "erb", "javascriptreact", "typescriptreact" },
    init_options = {
        showSuggestionsAsSnippets = true,
        html = { options = { ["jsx.enabled"] = true } },
        includeLanguages = { javascriptreact = "html", typescriptreact = "html" },
    },
})

lsp_config("jsonls", {
    before_init = function(_, newConfig)
        newConfig.settings.json.schemas = newConfig.settings.json.schemas or {}
        vim.list_extend(newConfig.settings.json.schemas, require("schemastore").json.schemas())
    end,
    settings = {
        json = {
            format = { enable = true },
            validate = { enable = true },
        },
    },
})

lsp_config("dockerls", {
    root_markers = { "Dockerfile" },
    cmd = { "docker-langserver", "--stdio" },
    filetypes = { "Dockerfile", "dockerfile" },
    settings = {
        docker = {
            languageserver = { formatter = { ignoreMultilineInstructions = true } },
        },
    },
})

lsp_config("cssls", {
    filetypes = { "css", "scss", "less" },
    settings = {
        css = {
            validate = true,
            hover = { documentation = true, references = true },
        },
        scss = {
            validate = true,
            hover = { documentation = true, references = true },
        },
    },
})

lsp_config("tailwindcss", {
    settings = {
        tailwindCSS = {
            classFunctions = { "css", "cn", "clsx", "cva", "twMerge", "twJoin" },
            classAttributes = {
                "class",
                "className",
                "class:list",
                "classList",
                "cva",
                "ngClass",
                "container",
                "bodyClassName",
            },
        },
    },
})

local typescript_settings = {
    format = { enable = true },
    inlayHints = {
        variableTypes = { enabled = true },
        parameterTypes = { enabled = true },
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
    },
    preferences = {
        quotePreference = "auto",
        useAliasesForRenames = true,
        importModuleSpecifier = "shortest",
        importModuleSpecifierEnding = "auto",
        jsxAttributeCompletionStyle = "auto",
    },
    suggest = {
        autoImports = true,
        completeFunctionCalls = true,
        includeCompletionsForImportStatements = true,
        paths = true,
    },
    updateImportsOnFileMove = { enabled = "prompt" },
    validate = { enable = true },
}

-- Use tsgo's built-in root_dir: it handles package roots, monorepos, and Deno exclusion.
lsp_config("tsgo", {
    settings = {
        typescript = vim.deepcopy(typescript_settings),
    },
})

lsp_config("yamlls", {
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            },
        },
    },
})

lsp_config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".git", ".luarc.json", ".stylua.toml" },
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            completion = { callSnippet = "Replace" },
            doc = { privateName = { "^_" } },
            diagnostics = { globals = { "vim" } },
            hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
            },
        },
    },
})

lsp_config("harper_ls", {
    cmd = { "harper-ls", "--stdio" },
    root_markers = { ".git" },
    filetypes = {
        "asciidoc",
        "c",
        "cpp",
        "cs",
        "gitcommit",
        "go",
        "html",
        "java",
        "javascript",
        "lua",
        "markdown",
        "nix",
        "python",
        "ruby",
        "rust",
        "swift",
        "toml",
        "typescript",
        "typescriptreact",
        "haskell",
        "cmake",
        "typst",
        "php",
        "dart",
        "clojure",
        "sh",
        "text",
        "plaintext",
        "tex",
    },
    settings = {
        ["harper-ls"] = {
            diagnosticSeverity = "hint",
        },
    },
})

lsp_config("oxlint", {
    root_markers = { "oxlint.json", ".oxlintrc.json", "oxlint.config.js", "oxlint.config.ts", "oxlint.config.mjs", "oxlint.config.cjs" },
})

vim.treesitter.language.register("markdown", "vimwiki")
vim.treesitter.language.register("bash", "kitty")
vim.treesitter.language.register("bash", "zsh")

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lsp-tailwind", { clear = true }),
    pattern = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
    callback = function()
        vim.lsp.enable "tailwindcss"
    end,
})

vim.lsp.enable(require("config.ensure-installed").lsp)
