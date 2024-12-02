-- https://github.com/vscode-langservers/vscode-json-languageserver
require('lspconfig').jsonls.setup {
  settings = {
    json = {
      schemas = {
        { fileMatch = { 'jsconfig.json' }, url = 'https://json.schemastore.org/jsconfig' },
        { fileMatch = { 'tsconfig.json' }, url = 'https://json.schemastore.org/tsconfig' },
        { fileMatch = { 'package.json' }, url = 'https://json.schemastore.org/package' },
        {
          fileMatch = { '.prettierrc.json', '.prettierrc' },
          url = 'https://json.schemastore.org/prettierrc.json',
        },
        { fileMatch = { '.eslintrc.json' }, url = 'https://json.schemastore.org/eslintrc.json' },
      },
    },
  },
  capabilities = require 'plugins.lsp.capabilities',
}
