-- https://github.com/vscode-langservers/vscode-css-languageserver-bin
require('lspconfig').cssls.setup {
    capabilities = require 'plugins.lsp.capabilities',
    settings = {
        css = {
            lint = {},
        },
    },
}
