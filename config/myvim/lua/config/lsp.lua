local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("kulala_ls", { capabilities = capabilities })
vim.lsp.config("css_variables", { capabilities = capabilities })
vim.lsp.config("docker_compose_language_service", { capabilities = capabilities })

vim.lsp.config("html", {
    filetypes = { "html" },
    capabilities = capabilities,
    cmd = { "vscode-html-language-server", "--stdio" },
})

vim.lsp.config("jsonls", {
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

vim.lsp.config("dockerls", {
    capabilities = capabilities,
    root_markers = { "Dockerfile" },
    cmd = { "docker-langserver", "--stdio" },
    filetypes = { "Dockerfile", "dockerfile" },
    settings = {
        docker = {
            languageserver = { formatter = { ignoreMultilineInstructions = true } },
        },
    },
})

vim.lsp.config("cssls", {
    capabilities = capabilities,
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

vim.lsp.config("tailwindcss", {
    capabilities = capabilities,
    name = "tailwindcss-language-server",
    cmd = { "tailwindcss-language-server", "--stdio" },
    pattern = {
        "html",
        "css",
        "scss",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
    },
    root_dir = vim.fs.dirname(vim.fs.find({
        "tailwind.config.js",
        "tailwind.config.cjs",
        "tailwind.config.mjs",
        "tailwind.config.ts",
        "postcss.config.js",
        "postcss.config.cjs",
        "postcss.config.mjs",
        "postcss.config.ts",
        "package.json",
        ".git",
    }, { upward = true })[1]),
    filetypes = {
        "astro",
        "astro-markdown",
        "blade",
        "clojure",
        "django-html",
        "htmldjango",
        "edge",
        "eelixir",
        "ejs",
        "erb",
        "eruby",
        "gohtml",
        "gohtmltmpl",
        "haml",
        "handlebars",
        "hbs",
        "html",
        "html-eex",
        "heex",
        "jade",
        "leaf",
        "liquid",
        "markdown",
        "mdx",
        "mustache",
        "njk",
        "nunjucks",
        "php",
        "razor",
        "slim",
        "twig",
        "css",
        "less",
        "postcss",
        "sass",
        "scss",
        "stylus",
        "sugarss",
        "javascript",
        "javascriptreact",
        "reason",
        "rescript",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "templ",
    },
    settings = {
        tailwindCSS = {
            classAttributes = {
                "class",
                "className",
                "class:list",
                "classList",
                "ngClass",
                "container",
                "bodyClassName",
            },
            lint = {
                invalidApply = "error",
                cssConflict = "warning",
                invalidScreen = "error",
                invalidVariant = "error",
                invalidConfigPath = "error",
                invalidTailwindDirective = "error",
                recommendedVariantOrder = "warning",
            },
            validate = true,
            colorDecorators = true,
            suggestions = true,
            hovers = true,
            codeActions = true,
            completion = true,
        },
    },
    init_options = { userLanguages = {} },
})

-- vim.lsp.config("vtsls", {
--     capabilities = capabilities,
--     filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
--     settings = {
--         refactor_auto_rename = true,
--         typescript = {
--             tsserver = { maxTsServerMemory = 12000 },
--             suggest = {
--                 enabled = true,
--                 completeFunctionCalls = true,
--             },
--             inlayHints = {
--                 variableTypes = { enabled = true },
--                 parameterTypes = { enabled = true },
--                 enumMemberValues = { enabled = true },
--                 parameterNames = { enabled = "literals" },
--                 functionLikeReturnTypes = { enabled = true },
--                 propertyDeclarationTypes = { enabled = true },
--             },
--         },
--     },
-- })

vim.lsp.config("yamlls", {
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            },
        },
    },
})

vim.lsp.config("lua_ls", {
    capabilities = capabilities,
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

vim.filetype.add {
    extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
    filename = {
        ["vifmrc"] = "vim",
    },
    pattern = {
        [".*/waybar/config"] = "jsonc",
        [".*/mako/config"] = "dosini",
        [".*/kitty/.+%.conf"] = "kitty",
        [".*/hypr/.+%.conf"] = "hyprlang",
        ["%.env%.[%w_.-]+"] = "sh",
    },
}
vim.treesitter.language.register("bash", "kitty")

vim.lsp.enable {
    "html",
    -- npm i -g bash-language-server
    "bashls",
    -- npm i -g vscode-langservers-extracted
    "cssls",
    "jsonls",
    -- npm i -g css-variables-language-server
    "css_variables",
    "denols",
    -- npm install -g dockerfile-language-server-nodejs
    "dockerls",
    -- npm install @microsoft/compose-language-service
    -- go install github.com/docker/docker-language-server/cmd/docker-language-server@latest
    "docker_compose_language_service",
    "docker_language_server",
    "lua_ls",
    -- "harper_ls",
    -- npm i -g oxlint
    "oxlint",
    "rust_analyzer",
    "tailwindcss",
    "vtsls",
    "yamlls",
}
