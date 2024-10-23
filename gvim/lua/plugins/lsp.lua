local vtslsServer = {
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    settings = {
        complete_function_calls = true,
        vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
                completion = {
                    enableServerSideFuzzyMatch = true,
                },
            },
        },
        typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = 'literals' },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
            },
        },
    },
}

local tailwindcssServer = {
    settings = {
        tailwindCSS = {
            classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass', 'container', 'bodyClassName', 'titleClassName' },
            lint = {
                cssConflict = 'error',
                invalidApply = 'error',
                invalidConfigPath = 'error',
                invalidScreen = 'error',
                invalidTailwindDirective = 'error',
                invalidVariant = 'error',
                recommendedVariantOrder = 'error',
            },
            validate = true,
        },
    },
}

return {
    { lazy = false,            'chrisgrieser/nvim-puppeteer' },
    { 'numToStr/Comment.nvim', opts = {} },
    {
        'olrtg/nvim-emmet',
        config = function()
            vim.keymap.set({ 'n', 'v' }, '<leader>ce', require('nvim-emmet').wrap_with_abbreviation)
        end,
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            { 'williamboman/mason.nvim', config = true },
            { 'Bilal2453/luvit-meta',    lazy = true },
            { 'j-hui/fidget.nvim',       opts = {} },
            {
                'folke/lazydev.nvim',
                ft = 'lua',
                opts = {
                    library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } },
                },
            },
        },
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end
                    -- Jump to the definition of the word under your cursor.
                    --  This is where a variable was first declared, or where a function is defined, etc.
                    --  To jump back, press <C-t>.
                    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                    -- Find references for the word under your cursor.
                    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                    -- Jump to the implementation of the word under your cursor.
                    --  Useful when your language has ways of declaring types without an actual implementation.
                    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                    -- Jump to the type of the word under your cursor.
                    --  Useful when you're not sure what type a variable is and you want to see
                    --  the definition of its *type*, not where it was *defined*.
                    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                    -- Fuzzy find all the symbols in your current document.
                    --  Symbols are things like variables, functions, types, etc.
                    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

                    -- Fuzzy find all the symbols in your current workspace.
                    --  Similar to document symbols, except searches over your entire project.
                    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                    -- Rename the variable under your cursor.
                    --  Most Language Servers support renaming across files, etc.
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header.
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
                            { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local lsp = require 'lspconfig'
            local lsp_flags = { allow_incremental_sync = true, debounce_text_changes = 150 }
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
            local language_servers = lsp.util.available_servers()
            for _, ls in ipairs(language_servers) do
                lsp[ls].setup { capabilities = capabilities }
            end
            require('ufo').setup()
            local servers = {
                cssls = {},
                html = {},
                bashls = {},
                eslint = {},
                tailwindcss = tailwindcssServer,
                yamlls = { settings = { yaml = { schemaStore = { enable = true, url = '' }, schemas = require('schemastore').yaml.schemas() } } },
                jsonls = { settings = { json = { schemas = require('schemastore').json.schemas(), validate = { enable = true } } } },
                lua_ls = { settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
                vtsls = vtslsServer,
                emmet_language_server = {},
            }
            require('mason').setup()
            -- You can add other tools here that you want Mason to install
            -- for you, so that they are available from within Neovim.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, { 'stylua', 'tailwindcss', 'vtsls', 'cssls', 'jsonls' })
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }
            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
            lsp.emmet_language_server.setup { capabilities = capabilities, flags = lsp_flags }
        end,
    },
    {
        'nvimtools/none-ls.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local c = require 'null-ls'
            c.setup {
                sources = {
                    c.builtins.code_actions.impl,
                    c.builtins.code_actions.refactoring,
                    c.builtins.code_actions.ts_node_action,
                    c.builtins.completion.luasnip,
                    c.builtins.completion.spell,
                    c.builtins.diagnostics.actionlint,
                    c.builtins.diagnostics.codespell,
                    c.builtins.diagnostics.editorconfig_checker,
                    c.builtins.diagnostics.markdownlint,
                    c.builtins.diagnostics.semgrep,
                    c.builtins.diagnostics.spectral,
                    c.builtins.diagnostics.sqlfluff.with { extra_args = { '--dialect', 'postgres' } },
                    c.builtins.formatting.rustywind,
                    c.builtins.formatting.shellharden,
                    c.builtins.formatting.shfmt,
                    c.builtins.formatting.stylua,
                    c.builtins.formatting.prettier.with {
                        filetypes = {
                            'javascript',
                            'javascriptreact',
                            'typescript',
                            'typescriptreact',
                            'vue',
                            'css',
                            'scss',
                            'less',
                            'html',
                            'json',
                            'jsonc',
                            'yaml',
                            'markdown',
                            'markdown.mdx',
                            'graphql',
                            'handlebars',
                            'svelte',
                            'astro',
                            'htmlangular',
                        },
                    },
                },
            }
        end,
    },
}
